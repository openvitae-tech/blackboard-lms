# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::FilterService do
  let(:service) { described_class.instance }
  let(:tags) { create_list(:tag, 3) }
  let(:user) { create(:user, role: :admin) }

  before do
    @course_one = create :course, tag_ids: [tags.first.id, tags.second.id]
    @course_two = create :course, tag_ids: [tags.last.id]
    @course_three = create :course
    @course_four = create :course, tag_ids: [tags.first.id, tags.last.id]
  end

  describe '#filter_courses' do
    context 'when the user is an admin' do
      it 'filter courses based on search term' do
        result = service.filter_courses(user, [], @course_one.title)
        expect(result[:available_courses].pluck(:id)).to eq([@course_one.id])
      end

      it 'filter courses based on tags' do
        result = service.filter_courses(user, [tags.second.name], '')
        expect(result[:available_courses].pluck(:id)).to eq([@course_one.id])
      end
    end
  end

  context 'when the user is an non-admin' do
    before do
      user.update!(role: :learner)
      @course_one.enroll!(user)
      @course_three.enroll!(user)
      @course_four.enroll!(user)
    end

    it 'filter courses based on search term' do
      result = service.filter_courses(user, [], @course_three.title)
      expect(result[:enrolled_courses].pluck(:id)).to eq([@course_three.id])
    end

    it 'filter courses based on tags' do
      result = service.filter_courses(user, [tags.second.name, tags.last.name], '')
      expect(result[:enrolled_courses].pluck(:id).sort).to eq([@course_one.id, @course_four.id].sort)
    end
  end
end
