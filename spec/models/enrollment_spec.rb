# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe '#complete_lesson!' do
    subject { described_class.new }

    it 'sets the current module and lesson id in course enrollment' do
      allow(subject).to receive(:save!).and_return(true)

      subject.complete_lesson!(1, 2, 10)
      expect(subject.current_module_id).to eq(1)
      expect(subject.current_lesson_id).to eq(2)
      expect(subject.completed_lessons).to eq([2])
      expect(subject.time_spent).to eq(10)
    end
  end
end
