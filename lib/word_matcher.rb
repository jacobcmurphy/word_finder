require 'set'
require_relative 'similarity_matcher'
  require 'pry'

class WordMatcher
  attr_accessor :word_ids
  attr_reader :params

  def initialize(params = {})
    @word_ids = Set.new
    @params = params
  end

  def get_words
    limit_words_by_params
    words = if params['sounds_like'].to_s.length.zero?
      Word.find(word_ids.to_a).pluck(:word)
    else
      word_similarity(params['sounds_like'], word_ids.count.zero? ? nil : word_ids)
    end
  end

  private

  def limit_words_by_params
    number_of_syllables(params['number_of_syllables']) unless params['number_of_syllables'].to_s == '0'
    primary_stress(params['primary_stress']) unless params['primary_stress'].to_i.to_s == '0'
    secondary_stress(params['secondary_stress']) unless params['secondary_stress'].to_i.to_s == '0'
    part_of_speech(params['part_of_speech']) unless params['part_of_speech'].to_s.length.zero?
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

  def word_similarity(word_to_compare_to, word_id_list = @word_ids)
    matcher = SimilarityMatcher.new(word_to_compare_to, word_id_list)
    matcher.match_words.map(&:first)
  end

  private

  def limit_ids(new_ids)
    @word_ids = @word_ids.empty? ? new_ids : (@word_ids & new_ids)
  end
end
