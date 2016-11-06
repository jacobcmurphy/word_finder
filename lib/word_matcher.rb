require 'set'

class WordMatcher
  attr_accessor :word_ids
  attr_reader :params

  def initialize(**params)
    @params = params
    @word_ids = Set.new
  end

  def number_of_syllables(num_syllables)
    new_ids = SyllableCount.where(number_of_syllables: num_syllables).pluck(:word_id)
    limit_ids(new_ids)
  end

  def part_of_speech(pos)
    new_ids = WordType.where(part_of_speech: pos).pluck(:word_id)
    limit_ids(new_ids)
  end

  def primary_stress(syllable_number)
    new_ids = Pronunciation.where(primary_stress: syllable_number.to_i).pluck(:word_id)
    limit_ids(new_ids)
 end

  def secondary_stress(syllable_number)
    new_ids = Pronunciation.where(secondary_stress: syllable_number.to_i).pluck(:word_id)
    limit_ids(new_ids)
  end

  def word_similarity(word_to_compare_to, word_id_list = []) # NEEDS TWEAKING
    phoneme_order = %w(ah ao aa uh ae ih eh ow ey ay iy er aw oy uw hh y m n b p f v th dh d t l w k s z g r jh ch sh zh ng)
    phoneme_position_weightings = [2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946]
    target_word = Word.find_by(word: word_to_compare_to)
    return [] unless target_word
    target_word_phonemes = target_word.pronunciations.first.cmu_notation.split.reverse

    if word_id_list.length.zero?
      num_syllables_in_target = target_word.syllable_counts.first.number_of_syllables
      word_id_list = SyllableCount.where(number_of_syllables: num_syllables_in_target-1..num_syllables_in_target+1).pluck(:word_id)
    end

    weighted_matches = {}
    phonemes = Pronunciation.where(word_id: word_id_list).includes(:word).sort_by do |pronunciation|
      word_weight = 0
      phonemes = pronunciation.cmu_notation.split.reverse
      number_of_phonemes_to_check = [target_word_phonemes.length, phonemes.length].min
      phonemes = phonemes.first(number_of_phonemes_to_check)
      phonemes.each_with_index do |phoneme, idx|
        phoneme_difference = ( phoneme_order.index(phoneme) - phoneme_order.index(target_word_phonemes[idx]) ).abs
        word_weight += phoneme_difference * phoneme_position_weightings[idx]
      end
      weighted_matches[pronunciation.word.word] = word_weight
      word_weight
    end
    weighted_matches.sort_by { |_k, value| value }
  end

  private

  def limit_ids(new_ids)
    @word_ids = @word_ids.empty? ? new_ids : (@word_ids & new_ids)
  end
end
