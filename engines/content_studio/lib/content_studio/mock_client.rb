# frozen_string_literal: true

module ContentStudio
  # In-process stub for the NeoAI microlesson API.
  # Used during development and testing before the real NeoAI endpoint is available.
  # Stores microlesson state in a class-level hash so successive get_microlesson
  # calls simulate the PLANNING → PLANNED → GENERATING → COMPLETED state machine.
  class MockClient
    MOCK_MICROLESSONS = {}.freeze

    # Advance through states on each poll: first two calls return PLANNING,
    # then PLANNED (with title/description), then two calls GENERATING, then COMPLETED.
    POLL_SEQUENCE = %w[PLANNING PLANNING PLANNED PLANNED GENERATING GENERATING COMPLETED].freeze

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
      self.class.store[id] = { poll_index: 0, prompt: prompt }
      id
    end

    def get_microlesson(microlesson_id)
      entry = self.class.store[microlesson_id] || { poll_index: 0 }
      index = entry[:poll_index].to_i
      status = POLL_SEQUENCE[index] || 'COMPLETED'

      # Advance the poll index (capped at last entry so it stays COMPLETED)
      self.class.store[microlesson_id] = entry.merge(poll_index: [index + 1, POLL_SEQUENCE.length - 1].min)

      build_microlesson(microlesson_id, status)
    end

    def replan_microlesson(microlesson_id:, prompt: nil, document_urls: nil) # rubocop:disable Lint/UnusedMethodArgument
      entry = self.class.store[microlesson_id] || {}
      # Reset back to PLANNING so the wizard re-polls from the start
      self.class.store[microlesson_id] = entry.merge(poll_index: 0, prompt: prompt)
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
