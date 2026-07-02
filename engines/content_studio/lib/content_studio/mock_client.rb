# frozen_string_literal: true

module ContentStudio
  # In-process stub for the NeoAI microlesson API.
  # Used during development and testing before the real NeoAI endpoint is available.
  # Stores microlesson state in a class-level hash so successive get_microlesson
  # calls simulate the PLANNING → PLANNED → GENERATING → COMPLETED state machine.
  #
  # Failure path: pass a prompt beginning with "fail_" to create_microlesson and
  # the sequence will resolve to FAILED instead of COMPLETED, making the FAILED
  # branch in build_microlesson reachable for UI/spec testing.
  class MockClient
    MOCK_MICROLESSONS = {}.freeze

    # Advance through states on each poll: first two calls return PLANNING,
    # then PLANNED (with title/description), then two calls GENERATING, then COMPLETED.
    POLL_SEQUENCE = %w[PLANNING PLANNING PLANNED PLANNED GENERATING GENERATING COMPLETED].freeze
    FAIL_SEQUENCE = %w[PLANNING PLANNING PLANNED PLANNED GENERATING GENERATING FAILED].freeze

    class << self
      def store
        @store ||= {}
      end

      def reset!
        @store = {}
      end
    end

    def create_microlesson(prompt:, document_urls: [], template_id: nil, logo_url: nil) # rubocop:disable Lint/UnusedMethodArgument
      id = "mock-ml-#{SecureRandom.hex(6)}"
      self.class.store[id] = { poll_index: 0, prompt: prompt, fail: prompt.to_s.start_with?('fail_') }
      id
    end

    def get_microlesson(microlesson_id)
      entry = self.class.store[microlesson_id] or
        raise Faraday::ResourceNotFound, "MockClient: microlesson #{microlesson_id} not found"
      index = entry[:poll_index].to_i
      sequence = entry[:fail] ? FAIL_SEQUENCE : POLL_SEQUENCE
      status = sequence[index] || sequence.last

      # Advance the poll index (capped at last entry so it stays in terminal state)
      self.class.store[microlesson_id] = entry.merge(poll_index: [index + 1, sequence.length - 1].min)

      build_microlesson(microlesson_id, status)
    end

    def replan_microlesson(microlesson_id:, prompt: nil, document_urls: nil) # rubocop:disable Lint/UnusedMethodArgument
      entry = self.class.store[microlesson_id] || {}
      # Reset back to PLANNING; only overwrite prompt/fail when a new prompt is given
      updates = { poll_index: 0 }
      updates.merge!(prompt: prompt, fail: prompt.to_s.start_with?('fail_')) if prompt
      self.class.store[microlesson_id] = entry.merge(updates)
      nil
    end

    def generate_microlesson(microlesson_id:)
      entry = self.class.store[microlesson_id] || {}
      # Jump to GENERATING state
      generating_index = POLL_SEQUENCE.index('GENERATING') || 4
      self.class.store[microlesson_id] = entry.merge(poll_index: generating_index)
      nil
    end

    private

    def build_microlesson(id, status)
      case status
      when 'PLANNING' then Microlesson.new(id: id, status: 'PLANNING')
      when 'PLANNED'  then planned_microlesson(id)
      when 'GENERATING'
        Microlesson.new(id: id, status: 'GENERATING', title: 'Banking and Basic Strategies')
      when 'COMPLETED' then completed_microlesson(id)
      when 'FAILED' then Microlesson.new(id: id, status: 'FAILED')
      end
    end

    def planned_microlesson(id)
      Microlesson.new(
        id: id,
        status: 'PLANNED',
        title: 'Banking and Basic Strategies',
        description: 'A concise overview of core banking operations and customer service principles for ' \
                     'front-line staff, covering account management, transaction handling, and complaint resolution.'
      )
    end

    def completed_microlesson(id)
      Microlesson.new(
        id: id,
        status: 'COMPLETED',
        title: 'Banking and Basic Strategies',
        description: 'A concise overview of core banking operations and customer service principles for ' \
                     'front-line staff, covering account management, transaction handling, and complaint resolution.',
        video_url: 'https://example.com/mock-microlesson.mp4',
        thumbnail_url: 'https://placehold.co/480x270?text=Microlesson',
        duration: 120
      )
    end
  end
end
