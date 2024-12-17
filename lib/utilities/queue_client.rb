# frozen_string_literal: true

module Utilities
  # A simple queue backed by redis
  class QueueClient
    attr_reader :redis_client

    def initialize(redis_client = REDIS_CLIENT)
      @redis_client = redis_client
    end

    def enqueue(queue_name, message)
      @redis_client.with do |redis|
        redis.call('LPUSH', queue_name, message)
      end
    end

    def clear_queue(queue_name)
      @redis_client.with do |redis|
        redis.call('DEL', queue_name)
      end
    end

    def trim_to_length(queue_name, length)
      @redis_client.with do |redis|
        redis.call('LTRIM', queue_name, 0, length - 1)
      end
    end

    def read_all(queue_name)
      count = length(queue_name)
      @redis_client.with do |redis|
        redis.call('LRANGE', queue_name, 0, count - 1)
      end
    end

    def length(queue_name)
      @redis_client.with do |redis|
        redis.call('LLEN', queue_name)
      end
    end

    def remove(queue_name, message)
      @redis_client.with do |redis|
        redis.call('LREM', queue_name, 1, message)
      end
    end
  end
end
