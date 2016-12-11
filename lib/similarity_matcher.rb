require 'pry'

class SimilarityMatcher
  attr_accessor :target_word, :word_id_list

  VOWEL_PHONEMES = %w(ah ao aa uh ae ih eh ow ey ay iy er aw oy uw )
  PHONEMES = (VOWEL_PHONEMES + %w(hh y m n b p f v th dh d t l w k s z g r jh ch sh zh ng)).freeze

  def initialize(target_word_text, word_id_list = [])
    @target_word = Word.find_by(word: target_word_text)
    @word_id_list = word_id_list.to_a
    limit_word_id_list
  end

  def match_words
    weighted_matches = {}

    Pronunciation.where(word_id: word_id_list).includes(:word).each do |pronunciation|
      phonemes = get_phonemes(pronunciation)
      weighted_matches[pronunciation.word.word] = calculate_word_weight(target_phonemes, phonemes)
    end

    matches = weighted_matches.sort_by { |_k, value| value }
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
    count = 0
    phonemes.each do |phoneme|
      count += 1 if is_vowel? phoneme
    end
    count
  end

  def get_phonemes(pronunciation)
    pronunciation.cmu_notation.split
  end

  def target_phonemes
    @_target_phonemes ||= get_phonemes(target_word.pronunciations.first)
  end

  def limit_word_id_list
    if @word_id_list.length.zero?
      num_syllables_in_target = target_word.syllable_counts.first.number_of_syllables
      @word_id_list = SyllableCount.where(number_of_syllables: num_syllables_in_target-1..num_syllables_in_target+1).pluck(:word_id)
    end
  end
end

# require_relative '../app'
# matcher = SimilarityMatcher.new('song')
# matcher.match_words
