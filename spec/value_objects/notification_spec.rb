# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Notification do
  let(:notification) { described_class.new(class_double(User), Faker::Lorem.sentence, Faker::Lorem.sentence) }

  describe '#new' do
    it 'creates a new notification' do
      expect(notification).to be_a(described_class)
      expect(notification.ntype).to eq('info')
    end

    it 'accepts notification type' do
      notification = described_class.new(
        class_double(User),
        Faker::Lorem.sentence,
        Faker::Lorem.sentence,
        link: '',
        ntype: 'error'
      )
      expect(notification.ntype).to eq('error')
    end

    it 'accepts timestamp' do
      notification = described_class.new(class_double(User), 'Sample notification', 'Notification text',
                                         timestamp: Time.now.to_i)
      expect(notification.created_at).to be_a(Time)
    end

    it 'throws error for invalid ntype' do
      expect do
        described_class.new(class_double(User), 'Title', 'Sample notification', ntype: 'random')
      end.to raise_error(Errors::InvalidNotificationType)
    end
  end

  describe '#to_json' do
    it 'returns json encoded value' do
      json_str = notification.to_json
      expect(JSON.parse(json_str)).to be_truthy
      expect(JSON.parse(json_str).keys).to eq(%w[title text link ntype timestamp])
    end
  end

  describe '#encoded_message' do
    it 'returns the CGI encoded message string' do
      encoded = notification.encoded_message
      expect(encoded).to be_a(String)
    end
  end
end
