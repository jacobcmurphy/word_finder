class CreatePronunciations < ActiveRecord::Migration
  def change
    create_table :pronunciations do |t|
      t.integer :word_id, index: true
      t.integer :primary_stress
      t.integer :secondary_stress
      t.string :cmu_notation
    end
  end
end
