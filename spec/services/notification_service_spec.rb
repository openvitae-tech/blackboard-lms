# frozen_string_literal: true

RSpec.fdescribe NotificationService do
  subject { described_class.instance }

  let(:queue_client) { instance_double(Utilities::QueueClient) }
  let(:user) { instance_double(User, id: 1) }
  let(:notification) { Notification.new(user, 'Simple notification') }
  let(:queue_name) { "notifications-#{user.id}" }

  before do
    # Stub QUEUE_CLIENT with a mock queue client
    stub_const('NotificationService::QUEUE_CLIENT', queue_client)
  end

  describe '.notify' do
    it 'enqueues a notification for the user' do
      allow(Notification).to receive(:new).and_return(notification)
      allow(subject).to receive(:enqueue_notification)
      allow(queue_client).to receive(:enqueue)

      described_class.notify(user, 'Simple notification')

      expect(Notification).to have_received(:new).with(user, notification.text, ntype: notification.ntype)
      expect(subject).to have_received(:enqueue_notification).with(notification)
    end
  end

  describe '#enqueue_notification' do
    it 'clears older notifications and enqueues a new notification' do
      allow(queue_client).to receive(:trim_to_length)
      allow(queue_client).to receive(:enqueue)

      subject.enqueue_notification(notification)

      expect(queue_client).to have_received(:trim_to_length).with(queue_name, 25)
      expect(queue_client).to have_received(:enqueue).with(queue_name, notification.encoded_message)
    end
  end

  describe '#pending_notification_for' do
    it 'returns a list of notifications for a user' do
      encoded_messages = [
        CGI.escape(Base64.encode64({ text: 'Message 1', ntype: 'info', timestamp: '123456' }.to_json)),
        CGI.escape(Base64.encode64({ text: 'Message 2', ntype: 'error', timestamp: '123457' }.to_json))
      ]

      allow(queue_client).to receive(:trim_to_length)
      allow(queue_client).to receive(:read_all).and_return(encoded_messages)

      notifications = subject.pending_notification_for(user)

      expect(queue_client).to have_received(:trim_to_length).with(queue_name, 25)
      expect(queue_client).to have_received(:read_all).with(queue_name)

      expect(notifications.size).to eq(2)
      expect(notifications[0]).to have_attributes(text: 'Message 1', ntype: 'info', timestamp: '123456')
      expect(notifications[1]).to have_attributes(text: 'Message 2', ntype: 'error', timestamp: '123457')
    end
  end

  describe '#notifications_count_for' do
    it 'returns the count of notifications for a user' do
      allow(queue_client).to receive(:length).and_return(5)
      count = subject.notifications_count_for(user)

      expect(queue_client).to have_received(:length).with(queue_name)
      expect(count).to eq(5)
    end
  end

  describe '#mark_as_read' do
    it 'removes a specific notification from the queue' do
      message = 'encoded_notification_message'
      allow(queue_client).to receive(:remove)
      subject.mark_as_read(user, message)

      expect(queue_client).to have_received(:remove).with(queue_name, message)
    end
  end

  describe '#mark_all_as_read' do
    it 'clears all notifications for the user' do
      allow(queue_client).to receive(:clear_queue)
      subject.mark_all_as_read(user)

      expect(queue_client).to have_received(:clear_queue).with(queue_name)
    end
  end
end
