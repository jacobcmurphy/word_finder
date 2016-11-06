require_relative 'seed_helpers/part_of_speech'
require_relative 'seed_helpers/pronunciation_seeder'
require_relative 'seed_helpers/word_initializer'

# Word.delete_all
# SyllableCount.delete_all
WordInitializer.new # creates Word records and SyllableCount records
puts 'Words and SyllableCounts added'

# WordType.delete_all
PartOfSpeech.new # creates WordType records
puts 'WordTypes added'

# Pronunciation.delete_all
PronunciationSeeder.new
puts 'Pronunciations added'
