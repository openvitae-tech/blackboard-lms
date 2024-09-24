# frozen_string_literal: true

class AddAnswerToQuizAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :quiz_answers, :answer, :string
  end
end
