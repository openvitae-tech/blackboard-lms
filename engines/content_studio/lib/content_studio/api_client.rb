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

      def course_structure(course_id) # rubocop:disable Rails/Delegate
        client.course_structure(course_id)
      end

      def save_course(course_id) # rubocop:disable Rails/Delegate
        client.save_course(course_id)
      end

      def discard_course(course_id) # rubocop:disable Rails/Delegate
        client.discard_course(course_id)
      end

      def get_lesson(course_id, lesson_id) # rubocop:disable Rails/Delegate
        client.get_lesson(course_id, lesson_id)
      end

      def create_course(files:, branding:)
        client.create_course(files: files, branding: branding)
      end

      def regenerate_scene(course_id, lesson_id, scene_id, narration:)
        client.regenerate_scene(course_id, lesson_id, scene_id, narration: narration)
      end

      private

      def client
        @client ||= NeoAiClient.new
      end
    end
  end
end
