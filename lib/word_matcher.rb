require 'set'
require_relative 'similarity_matcher'

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
    matcher = SimilarityMatcher.new(word_to_compare_to, word_id_list)
    matcher.match_words.map(&:first)
  end

  private

  def limit_ids(new_ids)
    @word_ids = @word_ids.empty? ? new_ids : (@word_ids & new_ids)
  end
end
