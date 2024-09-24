# frozen_string_literal: true

class AddSeqNoToCourseModule < ActiveRecord::Migration[7.1]
  def change
    add_column :course_modules, :seq_no, :integer
  end
end
