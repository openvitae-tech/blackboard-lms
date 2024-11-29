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
  end
end
