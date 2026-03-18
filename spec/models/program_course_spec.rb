# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProgramCourse, type: :model do
  let(:program) { create(:program) }
  let(:course) { create(:course) }

  describe 'uniqueness of course_id scoped to program_id' do
    before { create(:program_course, program: program, course: course) }

    it 'is invalid when the same course is added to the same program twice' do
      duplicate = build(:program_course, program: program, course: course)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:course_id]).to eq(["#{course.title} has already been added to this program"])
    end

    it 'is valid when the same course is added to a different program' do
      other_program = create(:program)
      expect(build(:program_course, program: other_program, course: course)).to be_valid
    end

    it 'is valid when a different course is added to the same program' do
      other_course = create(:course)
      expect(build(:program_course, program: program, course: other_course)).to be_valid
    end
  end
end
