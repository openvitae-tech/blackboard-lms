class CreateTranscripts < ActiveRecord::Migration[8.0]
  def change
    create_table :transcripts do |t|
      t.integer :start_at
      t.integer :end_at
      t.string :text
      t.references :local_content, null: false, foreign_key: true

      t.timestamps
    end
  end
end
