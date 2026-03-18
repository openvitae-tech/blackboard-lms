# frozen_string_literal: true

class SyncNeoAiCourseJob < BaseJob
  def perform(course_id)
    service = Webhooks::NeoAiSyncService.instance
    service.sync_course(course_id)
  end
end
