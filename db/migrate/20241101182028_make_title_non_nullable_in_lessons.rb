class MakeTitleNonNullableInLessons < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:lessons, :title, false)
  end
end
