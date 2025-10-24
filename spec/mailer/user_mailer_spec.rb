# frozen_string_literal: true

require 'rails_helper'

describe UserMailer, type: :mailer do
  describe 'course_assignment' do
    it 'renders the email with formatted name' do
      receiver_name = Faker::Name.name
      sender_name = Faker::Name.name
      learner = User.new(name: receiver_name, email: 'receiver@example.com', role: 'learner')
      manager = User.new(name: sender_name, email: 'manager@example.com', role: 'manager')
      course = Course.new(id: 1, title: 'My Course')

      mail = described_class.course_assignment(learner, manager, course)

      expect(mail.body.encoded).to include('New course assigned')
      expect(mail.body.encoded).to include(learner.display_name)
      expect(mail.body.encoded).to include(manager.display_name)
    end

    it 'cannot send course_completed email for support user' do
      support_user = create(:user, role: :support)
      course = create :course, :published

      mail = described_class.course_completed(support_user, course)

      expect(mail).not_to be_delivered
    end

    it 'cannot send course_deadline_reminder email for support user' do
      support_user = create(:user, role: :support)
      course = create :course, :published

      mail = described_class.course_deadline_reminder(support_user, course, Time.zone.today + 3.days)

      expect(mail).not_to be_delivered
    end

    it 'renders email when course assigned to a user by support user' do
      support_user = create(:user, role: :support)
      learner = create(:user, :learner)
      course = create :course, :published

      mail = described_class.course_assignment(learner, support_user, course)

      expect(mail.body.encoded).to include('New course assigned')
      expect(mail.body.encoded).to include(learner.display_name)
      expect(mail.body.encoded).to include(support_user.display_name)
    end
  end
end
