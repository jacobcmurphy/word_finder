require_relative'../../app'
class PronunciationSeeder
  def initialize(path = File.expand_path('../../../data_files/pronunciation.txt', __FILE__) )
    read_file(path)
  end

  def read_file(file_path)
    File.foreach(file_path, encoding: 'iso-8859-1:utf-8') do |line|
      line = line.strip.downcase
      word, *pronunciations = line.split
      word = word.downcase.gsub(/[^a-z']/, '')
      primary_stress_location, secondary_stress_location = get_stresses(pronunciations)
      pronunciation = pronunciations.map { |p| p.gsub(/\d/, '') }.join(' ')

      save_word(word, primary_stress_location, secondary_stress_location, pronunciation)
    end
  end

  def get_stresses(pronunciations)
    syllables = pronunciations.select { |p| p =~ /\d/ }
    primary_stress_location   = syllables.find_index { |p| p.include? '1' }
    secondary_stress_location = syllables.find_index { |p| p.include? '2' }

    return primary_stress_location ? primary_stress_location + 1 : nil, secondary_stress_location ? secondary_stress_location + 1 : nil
  end

  def save_word(word, primary_stress_syllable, secondary_stress_syllable, pronunciation)
    word = Word.find_by(word: word)
    if word
      word.pronunciations.create(
        cmu_notation: pronunciation,
        primary_stress: primary_stress_syllable,
        secondary_stress: secondary_stress_syllable
      )
    end
  end
end
