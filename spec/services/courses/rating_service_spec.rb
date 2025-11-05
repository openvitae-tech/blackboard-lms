# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::RatingService do
  subject { described_class.new }

  before do
    @course = create :course, :published
    @course_module = create :course_module, course: @course
    @lesson_one = create :lesson, course_module: @course_module
    @lesson_two = create :lesson, course_module: @course_module
  end

  describe '#process' do
    it 'calculates and updates course ratings based on lesson ratings' do
      @lesson_one.update!(rating: 4.0, last_rated_at: 2.days.ago)
      @lesson_two.update!(rating: 5.0, last_rated_at: 2.days.ago)

      subject.process
      @course.reload

      expected_average = (@lesson_one.current_rating + @lesson_two.current_rating) / 2
      expect(@course.rating).to eq(expected_average.round(1))
    end
  end
end
