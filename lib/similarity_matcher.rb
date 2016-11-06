# require_relative 'app'
# matcher = SimilarityMatcher.new('tomcat')
# matcher.match_words

class SimilarityMatcher
  attr_accessor :target_word, :word_id_list

  VOWEL_MULTIPLIER = 10
  VOWEL_PHONEMES = %w(ah ao aa uh ae ih eh ow ey ay iy er aw oy uw )
  PHONEMES = (VOWEL_PHONEMES + %w(hh y m n b p f v th dh d t l w k s z g r jh ch sh zh ng)).freeze
  POSITION_WEIGHTINGS = [2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946].freeze

  def initialize(target_word_text, word_id_list = [])
    @target_word = Word.find_by(word: target_word_text)
    @word_id_list = word_id_list
    limit_word_id_list
  end

  def match_words
    weighted_matches = {}

    Pronunciation.where(word_id: word_id_list).includes(:word).each do |pronunciation|
      phonemes = get_phonemes(pronunciation)
      word_weight = phonemes.each_with_index.inject(0) do |sum, (phoneme, idx)|
        sum + relative_phoneme_weighting(phoneme, idx)
      end
      weighted_matches[pronunciation.word.word] = word_weight
    end

    weighted_matches.sort_by { |_k, value| value }
  end

  private

  def relative_phoneme_weighting(phoneme, idx)
    phoneme_difference = ( PHONEMES.index(phoneme) - PHONEMES.index(target_phonemes[idx]) ).abs
    phoneme_difference = apply_multiplier?(phoneme, target_phonemes[idx]) ? phoneme_difference * VOWEL_MULTIPLIER : phoneme_difference
    phoneme_difference * POSITION_WEIGHTINGS[idx]
  end

  def apply_multiplier?(phoneme_one, phoneme_two)
    first_is_vowel = is_vowel? phoneme_one
    second_is_vowel = is_vowel? phoneme_two

    (first_is_vowel && !second_is_vowel) || (!first_is_vowel && second_is_vowel)
  end

  def is_vowel?(phoneme)
    VOWEL_PHONEMES.include? phoneme
  end

  def get_phonemes(pronunciation)
    phonemes = pronunciation.cmu_notation.split.reverse
    number_of_phonemes_to_check = [target_phonemes.length, phonemes.length].min
    phonemes.first(number_of_phonemes_to_check)
  end

  def target_phonemes
    @_target_phonemes ||= target_word.pronunciations.first.cmu_notation.split.reverse
  end

  def limit_word_id_list
    if @word_id_list.length.zero?
      num_syllables_in_target = target_word.syllable_counts.first.number_of_syllables
      @word_id_list = SyllableCount.where(number_of_syllables: num_syllables_in_target-1..num_syllables_in_target+1).pluck(:word_id)
    end
  end
end
