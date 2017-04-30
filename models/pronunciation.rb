class Pronunciation < ActiveRecord::Base
  belongs_to :word

  def phonemes
    cmu_notation.split
  end
end
