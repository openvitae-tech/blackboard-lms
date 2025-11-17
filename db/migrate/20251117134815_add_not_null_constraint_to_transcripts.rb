class AddNotNullConstraintToTranscripts < ActiveRecord::Migration[8.0]
  def change
    change_table :transcripts, bulk: true do |t|
      t.change_null :start_at, false
      t.change_null :end_at, false
      t.change_null :text, false
    end
  end
end
