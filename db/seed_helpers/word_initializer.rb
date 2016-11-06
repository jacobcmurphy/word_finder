require_relative '../../app'
require 'pry'
class WordInitializer
  def initialize(path = File.expand_path('../../../data_files/syllables.txt', __FILE__) )
    read_file(path)
  end

  def read_file(file_path)
    File.foreach(file_path, encoding: 'iso-8859-1:utf-8') do |line|
      word = line.strip.downcase
      syllable_count = 1 + word.count('*') + word.count(' ')
      word = word.tr('*', '')
      save_word(word, syllable_count)
    end
  end

  def save_word(word, number_of_syllables)
    word = Word.create(word: word)
    word.syllable_counts.create(number_of_syllables: number_of_syllables)
  end
end
