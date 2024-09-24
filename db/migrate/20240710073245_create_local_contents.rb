# frozen_string_literal: true

class CreateLocalContents < ActiveRecord::Migration[7.1]
  def change
    create_table :local_contents do |t|
      t.string :lang
      t.string :video_url
      t.references :lesson, null: false, foreign_key: true

      t.timestamps
    end
  end
end
