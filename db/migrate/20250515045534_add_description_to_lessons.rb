class AddDescriptionToLessons < ActiveRecord::Migration[7.2]
  def up
    add_column :lessons, :description, :text

    Lesson.reset_column_information

    Lesson.find_each do |lesson|
      rich_text = ActionText::RichText.find_by(record_type: "Lesson", record_id: lesson.id, name: "rich_description")
      if rich_text.present?
        lesson.update!(description: rich_text.body.to_plain_text)
      end
    end
  end

  def down
    remove_column :lessons, :description
  end
end
