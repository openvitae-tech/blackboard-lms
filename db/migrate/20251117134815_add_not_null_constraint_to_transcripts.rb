class AddNotNullConstraintToTranscripts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :transcripts, :start_at, false
    change_column_null :transcripts, :end_at, false
    change_column_null :transcripts, :text, false
  end
end
