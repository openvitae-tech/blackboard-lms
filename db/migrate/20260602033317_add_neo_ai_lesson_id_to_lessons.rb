class AddNeoAiLessonIdToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :neo_ai_lesson_id, :string
  end
end
