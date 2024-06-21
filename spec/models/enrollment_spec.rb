require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe "#set_progress!" do
    subject { Enrollment.new }

    it "sets the current module and lesson id in course enrollment" do
      allow(subject).to receive(:save!).and_return(true)

      subject.set_progress!(1, 2)
      expect(subject.current_module_id).to eq(1)
      expect(subject.current_lesson_id).to eq(2)
      expect(subject.completed_lessons).to eq([2])
    end
  end
end
