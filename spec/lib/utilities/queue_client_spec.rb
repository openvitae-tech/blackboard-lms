# frozen_string_literal: true

require 'rails_helper'
require 'utilities/queue_client'

describe Utilities::QueueClient do
  subject { described_class }

  let(:redis_client) { class_double(RedisClient) }
  let(:redis_connection) { instance_double(RedisClient) }

  let(:queue_client) { subject.new(redis_client) }
  let(:queue_name) { 'test_queue' }
  let(:message) { 'test_message' }

  before do
    allow(redis_client).to receive(:with).and_yield(redis_connection)
    allow(redis_connection).to receive(:call) # Allow all call method invocations
  end

  describe '#enqueue' do
    it 'calls LPUSH on Redis to add a message to the queue' do
      queue_client.enqueue(queue_name, message)

      expect(redis_connection).to have_received(:call).with('LPUSH', queue_name, message)
    end
  end

  describe '#clear_queue' do
    it 'calls DEL on Redis to clear the queue' do
      queue_client.clear_queue(queue_name)

      expect(redis_connection).to have_received(:call).with('DEL', queue_name)
    end
  end

  describe '#trim_to_length' do
    it 'calls LTRIM on Redis to trim the queue to a specified length' do
      length = 5
      queue_client.trim_to_length(queue_name, length)

      expect(redis_connection).to have_received(:call).with('LTRIM', queue_name, 0, length - 1)
    end
  end

  describe '#read_all' do
    it 'calls LLEN and LRANGE to fetch all messages from the queue' do
      queue_length = 3

      # Stub LLEN to return the queue length
      allow(redis_connection).to receive(:call).with('LLEN', queue_name).and_return(queue_length)

      queue_client.read_all(queue_name)

      # Verify LRANGE was called with the correct range
      expect(redis_connection).to have_received(:call).with('LLEN', queue_name)
      expect(redis_connection).to have_received(:call).with('LRANGE', queue_name, 0, queue_length - 1)
    end
  end

  describe '#length' do
    it 'calls LLEN on Redis to get the length of the queue' do
      queue_client.length(queue_name)

      expect(redis_connection).to have_received(:call).with('LLEN', queue_name)
    end
  end

  describe '#remove' do
    it 'calls LREM on Redis to remove a message from the queue' do
      queue_client.remove(queue_name, message)

      expect(redis_connection).to have_received(:call).with('LREM', queue_name, 1, message)
    end
  end
end
