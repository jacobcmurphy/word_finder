require_relative '../../app'
class PartOfSpeech
  def initialize(file_path = File.expand_path('../../../data_files/pos.txt', __FILE__) )
    read_file(file_path)
  end

  def read_file(file_path)
    File.foreach(file_path, encoding: 'iso-8859-1:utf-8') do |line|
      line = line.strip
      if line.length > 0
        word, pos = line.split('*')
        pos_arr = parse_part_of_speeches(pos)
        pos_arr.each { |pos| save_word(word.downcase, pos) }
      end
    end
  end

  def parse_part_of_speeches(pos_section)
    pos_arr = []
    pos_section.split('').each do |char|
      pos = case char
      when 'N' then 'noun'
      when 'p' then 'plural'
      when 'h' then 'noun_phrase'
      when 'V' then 'verb_participle'
      when 't' then 'verb_transitive'
      when 'i' then 'verb_intransitive'
      when 'A' then 'adjective'
      when 'v' then 'adverb'
      when 'C' then 'conjunction'
      when 'P' then 'preposition'
      when '!' then 'interjection'
      when 'r' then 'pronoun'
      when 'D' then 'article_definite'
      when 'I' then 'article_indefinite'
      when 'o' then 'nominative'
      else 'unknown'
      end
      pos_arr << pos
    end
    pos_arr
  end

  def save_word(word, pos)
    record = Word.find_by(word: word)
    if record
      record.word_types.create(part_of_speech: pos)
    end
  end
end
