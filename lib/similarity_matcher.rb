require_relative '../models/pronunciation'
require_relative '../models/syllable_count'

class SimilarityMatcher
  attr_accessor :target_word, :word_id_list

  VOWEL_PHONEMES = %w(ah ao aa uh ae ih eh ow ey ay iy er aw oy uw )
  PHONEMES = (VOWEL_PHONEMES + %w(hh y m n b p f v th dh d t l w k s z g r jh ch sh zh ng)).freeze

  def initialize(target_word, word_id_list = [])
    @target_word = target_word
    @word_id_list = word_id_list.size.zero? ? default_word_id_list : word_id_list
  end

  def words
    @_words ||= weighted_matches.map(&:first)
  end

  def weighted_matches
    @_weighted_matches ||= begin
      matches = {}

      Pronunciation.where(word_id: word_id_list).includes(:word).each do |pronunciation|
        matches[pronunciation.word] = calculate_word_weight(target_phonemes, pronunciation.phonemes)
      end

      matches.sort_by { |_k, value| value }
    end
  end

  def calculate_word_weight(target_phonemes, new_phonemes)
    num_phonemes = [target_phonemes.length, new_phonemes.length].min
    relevant_phonemes = target_phonemes.last(num_phonemes).reverse.zip(new_phonemes.last(num_phonemes).reverse)
    total_vowels = count_vowels(relevant_phonemes.flatten)
    vowel_count = 0
    word_weight = relevant_phonemes.inject(0) do |sum, (target_phoneme, new_phoneme)|
      val = sum + relative_phoneme_weighting(target_phoneme, new_phoneme, vowel_count, total_vowels)
      vowel_count += 1 if is_vowel? target_phoneme
      vowel_count += 1 if is_vowel? new_phoneme
      val
    end
  end

  private

  def relative_phoneme_weighting(target_phoneme, new_phoneme, vowel_count, total_vowels)
    weight = ( PHONEMES.index(new_phoneme) - PHONEMES.index(target_phoneme) ).abs
    weight * get_modifier(target_phoneme, new_phoneme, vowel_count, total_vowels)
  end

  def get_modifier(target_phoneme, new_phoneme, vowel_count, total_vowels)
    target_is_vowel = is_vowel? target_phoneme
    new_is_vowel = is_vowel? new_phoneme

    mult = (total_vowels - vowel_count) * PHONEMES.count
    !target_is_vowel || !new_is_vowel ? mult * 2 : mult
  end

  def is_vowel?(phoneme)
    VOWEL_PHONEMES.include? phoneme
  end

  def count_vowels(phonemes)
    phonemes.select { |p| is_vowel? p }.count
  end

  def target_phonemes
    @_target_phonemes ||= target_word.pronunciations.first.phonemes
  end

  def default_word_id_list
    num_syllables_in_target = target_word.syllable_counts.first.number_of_syllables
    SyllableCount.where(number_of_syllables: num_syllables_in_target-1..num_syllables_in_target+1).pluck(:word_id)
  end
end

# require_relative '../app'
# matcher = SimilarityMatcher.new(Word.find_by(word: 'song'))
# matcher.words
