# frozen_string_literal: true

class CreateLessons < ActiveRecord::Migration[7.1]
  def change
    create_table :lessons do |t|
      t.string :title
      t.text :description
      t.string :video_url
      t.string :pdf_url
      t.string :lesson_type
      t.string :video_streaming_source
      t.references :course_module, null: false, foreign_key: true

      t.timestamps
    end
  end
end
