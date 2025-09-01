# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Program, type: :model do
  let(:learning_partner) { create :learning_partner }
  let(:user) { create :user, :learner, learning_partner: }

  let(:course) { create :course }
  let(:program) { create :program, courses: [course], users: [user], learning_partner: }

  describe '#name' do
    it 'is not valid without name' do
      program.name = ''
      expect(program).not_to be_valid
      expect(program.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                               field: 'Name'))
    end
  end

  describe 'when adding associated records' do
    it 'increments courses_count when a course is added' do
      new_course = create(:course)
      expect do
        program.update!(courses: [course, new_course])
      end.to change { program.reload.courses_count }.by(1)
    end

    it 'increments users_count when a user is added' do
      new_user = create(:user, :learner)
      expect do
        program.update!(users: [user, new_user])
      end.to change { program.reload.users_count }.by(1)
    end
  end

  context 'when learning_partner is missing' do
    it 'is not valid' do
      program.learning_partner = nil
      expect(program).not_to be_valid
      expect(program.errors.full_messages.to_sentence).to eq(t('must_exist', entity: 'Learning partner'))
    end
  end
end
