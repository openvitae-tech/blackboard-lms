class CreateTranscripts < ActiveRecord::Migration[8.0]
  def change
    create_table :transcripts do |t|
      t.integer :start_at, null: false
      t.integer :end_at, null: false
      t.string :text, null: false
      t.references :local_content, null: false, foreign_key: true

      t.timestamps
    end
  end
end
