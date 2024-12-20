# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::FilterService do
  let(:service) { described_class.instance }
  let(:category_tags) { create_list(:tag, 3) }
  let(:level_tags) { create_list(:tag, 2, tag_type: :level) }

  let(:user) { create(:user, role: :admin) }

  before do
    @course_one = create :course, tag_ids: [category_tags.first.id, level_tags.first.id]
    @course_two = create :course, tag_ids: [category_tags.last.id, level_tags.first.id]
    @course_three = create :course
    @course_four = create :course, tag_ids: [category_tags.second.id, level_tags.last.id]
  end

  describe '#filter_courses' do
    context 'when the user is an admin' do
      it 'filter courses based on search term' do
        result = service.filter_courses(user, [], @course_one.title)
        expect(result[:available_courses].pluck(:id)).to eq([@course_one.id])
      end

      it 'filter courses based on tags' do
        result = service.filter_courses(user, [category_tags.second.name], '')
        expect(result[:available_courses].pluck(:id)).to eq([@course_four.id])
      end

      it 'returns no available courses when there are no matching tags' do
        result = service.filter_courses(user, [category_tags.second.name, level_tags.first.name], '')
        expect(result[:available_courses]).to be_empty
      end
    end
  end

  context 'when the user is an non-admin' do
    before do
      user.update!(role: :learner)
      @course_one.enroll!(user)
      @course_two.enroll!(user)
      @course_three.enroll!(user)
      @course_four.enroll!(user)
    end

    it 'filter courses based on search term' do
      result = service.filter_courses(user, [], @course_three.title)
      expect(result[:enrolled_courses].pluck(:id)).to eq([@course_three.id])
    end

    it 'filter courses based on tags' do
      result = service.filter_courses(user, [category_tags.last.name, level_tags.first.name], '')
      expect(result[:enrolled_courses].pluck(:id)).to eq([@course_two.id])

      result = service.filter_courses(user, [level_tags.first.name], '')
      expect(result[:enrolled_courses].pluck(:id)).to eq([@course_one.id, @course_two.id])
    end

    it 'returns no enrolled courses when there are no matching tags' do
      result = service.filter_courses(user, [category_tags.first.name, level_tags.last.name], '')
      expect(result[:enrolled_courses]).to be_empty
    end
  end
end
