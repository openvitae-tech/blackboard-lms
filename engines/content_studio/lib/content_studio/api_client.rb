# frozen_string_literal: true

module ContentStudio
  # Single entry point for all data access within Content Studio.
  # Always delegates to BlackboardClient which calls the BlackboardLMS internal API.
  # In development, internal API requests are intercepted by the stub controller
  # which serves fixture JSON from spec/fixtures/api/.
  #
  # Never call BlackboardClient directly from views or controllers — always go through ApiClient.
  class ApiClient
    thread_mattr_accessor :current_cookie
    thread_mattr_accessor :cached_client
    thread_mattr_accessor :cached_client_cookie

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

      def create_course(files:, branding:, no_video: false)
        client.create_course(files: files, branding: branding, no_video: no_video)
      end

      def regenerate_scene(scene_id, course_id:, lesson_id:, narration:)
        client.regenerate_scene(scene_id, course_id: course_id, lesson_id: lesson_id, narration: narration)
      end

      def verify_lesson(lesson_id, course_id:)
        client.verify_lesson(lesson_id, course_id: course_id)
      end

      def reorder_lesson(lesson_id, course_id:, new_position:)
        client.reorder_lesson(lesson_id, course_id: course_id, new_position: new_position)
      end

      def delete_module(module_id, course_id:)
        client.delete_module(module_id, course_id: course_id)
      end

      def delete_lesson(lesson_id, course_id:)
        client.delete_lesson(lesson_id, course_id: course_id)
      end

      def regenerate_lesson(lesson_id, course_id:)
        client.regenerate_lesson(lesson_id, course_id: course_id)
      end

      def create_classroom_kit(files:, components:, title: nil)
        client.create_classroom_kit(files: files, components: components, title: title)
      end

      def save_classroom_kit(kit_id) # rubocop:disable Rails/Delegate
        client.save_classroom_kit(kit_id)
      end

      delegate :get_classroom_kit, :discard_kit, to: :client

      private

      def client
        if cached_client.nil? || cached_client_cookie != current_cookie
          self.cached_client_cookie = current_cookie
          self.cached_client = BlackboardClient.new(cookie: current_cookie)
        end
        cached_client
      end
    end
  end
end
