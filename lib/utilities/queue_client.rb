# frozen_string_literal: true

module Utilities
  # A simple queue backed by redis
  class QueueClient
    attr_reader :redis_client

    def initialize(redis_client = REDIS_CLIENT)
      @redis_client = redis_client
    end

    def enqueue(queue_name, message)
      @redis_client.call('LPUSH', queue_name, message)
    end

    def clear_queue(queue_name)
      @redis_client.call('DEL', queue_name)
    end

    def trim_to_length(queue_name, length)
      @redis_client.call('LTRIM', queue_name, 0, length - 1)
    end

    def read_all(queue_name)
      count = length(queue_name)
      @redis_client.call('LRANGE', queue_name, 0, count - 1)
    end

    def length(queue_name)
      @redis_client.call('LLEN', queue_name)
    end

    def remove(queue_name, message)
      @redis_client.call('LREM', queue_name, 1, message)
    end
  end
end
