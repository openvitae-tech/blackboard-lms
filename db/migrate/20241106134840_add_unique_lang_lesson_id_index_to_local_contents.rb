class AddUniqueLangLessonIdIndexToLocalContents < ActiveRecord::Migration[7.2]
  def change
    add_index :local_contents, [:lesson_id, :lang], unique: true
  end
end
