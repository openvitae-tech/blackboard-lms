# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lessons::RatingService do
  subject { described_class.instance }

  let(:user) { create :user, :learner }
  let(:lesson) { create :lesson }

  describe '#rate_lesson!' do
    it 'logs the lesson rating event' do
      expect do
        subject.rate_lesson!(user, lesson, 4.0)
      end.to change(Event, :count).by(1)
    end
  end

  describe '#calculate_ratings' do
    it 'calculates and updates lesson ratings based on events for a lesson with no rating' do
      create(:event, name: 'lesson_rating', data: { 'lesson_id' => lesson.id, 'rating' => 4.0 },
                     created_at: Date.yesterday)
      create(:event, name: 'lesson_rating', data: { 'lesson_id' => lesson.id, 'rating' => 5.0 },
                     created_at: Date.yesterday)

      subject.calculate_ratings
      lesson.reload

      expected_average = (4.0 + 5.0) / 2
      expected_new_rating = 0.5 * (expected_average + (Lessons::RatingService::DISCOUNTED_FACTOR * 0))
      expect(lesson.rating).to eq(expected_new_rating.round(1))
    end

    it 'calculates and updates lesson ratings based on events for a lesson with rating' do
      lesson.update!(rating: 3.0, last_rated_at: 2.days.ago)
      current_rating = lesson.current_rating

      create(:event, name: 'lesson_rating', data: { 'lesson_id' => lesson.id, 'rating' => 4.0 },
                     created_at: Date.yesterday)

      subject.calculate_ratings
      lesson.reload

      expected_average = 4.0 / 1
      expected_new_rating = 0.5 * (expected_average + (Lessons::RatingService::DISCOUNTED_FACTOR * current_rating))
      expect(lesson.rating).to eq(expected_new_rating.round(1))
    end
  end

  describe '#diminished_rating' do
    it 'calculates diminished rating' do
      last_rated_at = 10.days.ago
      original_rating = 4.0

      diminished = subject.diminished_rating(original_rating, last_rated_at)

      no_days_since_last_rating = ((Time.current - last_rated_at) / 1.day).to_i
      diminishing_rate = Lessons::RatingService::DIMINISHING_WINDOW / [Lessons::RatingService::DIMINISHING_WINDOW,
                                                                       no_days_since_last_rating].max
      expected_diminished = [5, (original_rating * diminishing_rate) + Lessons::RatingService::EPSILON].min

      expect(diminished).to eq(expected_diminished.round(1))
    end
  end
end
