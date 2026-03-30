# frozen_string_literal: true

module ContentStudio
  # Single entry point for all data access within Content Studio.
  # Delegates to MockClient during development (Phase 1 & 2).
  # Swap to RealClient in Phase 3 by implementing the same interface.
  #
  # Never call MockClient or RealClient directly from views or controllers —
  # always go through ApiClient.
  class ApiClient
    class << self
      def list_courses # rubocop:disable Rails/Delegate
        client.list_courses
      end

      def find_course(id) # rubocop:disable Rails/Delegate
        client.find_course(id)
      end

      def current_user # rubocop:disable Rails/Delegate
        client.current_user
      end

      private

      def client
        @client ||= MockClient.new
      end
    end
  end
end
