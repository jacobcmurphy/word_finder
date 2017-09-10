require 'pry'
require_relative 'similarity_matcher'
require_relative '../models/word'
require_relative '../models/pronunciation.rb'
require_relative '../models/syllable_count.rb'
require_relative '../models/word_type.rb'

class WordMatcher
  attr_accessor :word_ids
  attr_reader :params

  def initialize(params = {})
    @query = Word.all
    @params = params
    @joined_to = {}
  end

  def get_words
    limit_words_by_params
    if params['sounds_like'].to_s.length.zero?
      @query
    else
      word_similarity(params['sounds_like'])
    end
  end

  private

  def limit_words_by_params
    number_of_syllables(params['number_of_syllables']) unless params['number_of_syllables'].to_i < 1
    part_of_speech(params['part_of_speech']) unless params['part_of_speech'].to_s.length.zero?
    primary_stress(params['primary_stress']) unless params['primary_stress'].to_i < 1
    secondary_stress(params['secondary_stress']) unless params['secondary_stress'].to_i < 1
  end

  def number_of_syllables(num_syllables)
    @query = join_associated(:syllable_counts).where(syllable_counts: { number_of_syllables: num_syllables })
  end

  def part_of_speech(pos)
    @query = join_associated(:word_types).where(word_types: { part_of_speech: pos })
  end

  def primary_stress(syllable_number)
    @query = join_associated(:pronunciations).where(pronunciations: { primary_stress: syllable_number.to_i })
 end

  def secondary_stress(syllable_number)
    @query = join_associated(:pronunciations).where(pronunciations: { secondary_stress: syllable_number.to_i })
  end

  def word_similarity(word_to_compare_to)
    target_word = Word.find_by(word: word_to_compare_to)
    SimilarityMatcher.new(target_word, @query.pluck(:id)).words
  end

  private

  def join_associated(join_symbol)
    return @query if @joined_to[join_symbol]

    @query = @query.joins(join_symbol)
    @joined_to[join_symbol] = true
    @query
  end
end
