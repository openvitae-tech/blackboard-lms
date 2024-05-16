class AddSeqNoToLesson < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :seq_no, :integer
  end
end
