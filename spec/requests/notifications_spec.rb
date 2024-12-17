# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request specs for notifications', type: :request do
  let(:team) { create :team }
  let(:user) { create :user, :learner, team:, learning_partner: team.learning_partner }

  before do
    sign_in user
    # clear any previous notifications
    NotificationService.instance.mark_all_as_read(user)
  end

  describe 'GET #index' do
    it 'returns the pending notifications for the user' do
      messages = enqueue_test_notifications

      get notifications_path, as: :turbo_stream
      expect(response).to have_http_status(:ok)
      expect(assigns(:notifications).length).to eq(3)
      expect(assigns(:notifications).map(&:text).sort).to eq(messages.map(&:text).sort)
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #count' do
    it 'returns the count of pending notifications' do
      enqueue_test_notifications
      get count_notifications_path, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(assigns(:notifications_count)).to eq(3)
      expect(response).to render_template(:count)
    end
  end

  describe 'GET #clear' do
    it 'marks all notifications as read' do
      enqueue_test_notifications

      get clear_notifications_path, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:clear)
    end
  end

  describe 'POST #mark_as_read' do
    it 'marks a specific notification as read and fetches updated notifications' do
      notifications = enqueue_test_notifications

      get mark_as_read_notifications_path, params: { message: notifications[0].encoded_message }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(assigns(:notifications).length).to eq(2)
      expect(response).to render_template(:mark_as_read)
    end
  end

  def enqueue_test_notifications(count = 3)
    count.times.map do
      n = Notification.new(user, Faker::Lorem.sentence)
      NotificationService.instance.enqueue_notification(n)
      n
    end
  end
end
