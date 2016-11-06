class CreateWordTypes < ActiveRecord::Migration
  def change
    create_table :word_types do |t|
      t.integer :word_id, index: true
      t.string :part_of_speech, index: true
    end
  end
end
