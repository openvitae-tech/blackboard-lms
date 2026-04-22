# frozen_string_literal: true

module ContentStudio
  # Single entry point for all data access within Content Studio.
  # Always delegates to BlackboardClient which calls the BlackboardLMS internal API.
  # In development, internal API requests are intercepted by the stub controller
  # which serves fixture JSON from spec/fixtures/api/.
  #
  # Never call BlackboardClient directly from views or controllers — always go through ApiClient.
  class ApiClient
    class << self
      def list_courses # rubocop:disable Rails/Delegate
        client.list_courses
      end

      def find_course(id) # rubocop:disable Rails/Delegate
        client.find_course(id)
      end

      def course_stats # rubocop:disable Rails/Delegate
        client.course_stats
      end

      def list_courses_by_status(status) # rubocop:disable Rails/Delegate
        client.list_courses_by_status(status)
      end

      def current_user # rubocop:disable Rails/Delegate
        client.current_user
      end

      def list_avatars # rubocop:disable Rails/Delegate
        client.list_avatars
      end

      def list_templates # rubocop:disable Rails/Delegate
        client.list_templates
      end

      def course_metadata # rubocop:disable Rails/Delegate
        client.course_metadata
      end

      def generation_status(course_id) # rubocop:disable Rails/Delegate
        client.generation_status(course_id)
      end

      private

      def client
        @client ||= BlackboardClient.new
      end
    end
  end
end
