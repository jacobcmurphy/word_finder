class CreateSyllableCounts < ActiveRecord::Migration
  def change
    create_table :syllable_counts do |t|
      t.integer :word_id, index: true
      t.integer :number_of_syllables, index: true
    end
  end
end
