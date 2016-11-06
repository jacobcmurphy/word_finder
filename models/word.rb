class Word < ActiveRecord::Base
  has_many :pronunciations
  has_many :word_types
  has_many :syllable_counts
end
