# frozen_string_literal: true

module ContentStudio
  # Lightweight value objects used as data transfer objects between the
  # ApiClient and Content Studio views. Plain structs — no ActiveRecord, no persistence.
  # Shape mirrors CourseJson#to_json_data from BlackboardLMS.

  LocalContent = Struct.new(
    :id,
    :lang,
    :status,
    :video_url,
    :video_published_at,
    keyword_init: true
  )

  Scene = Struct.new(
    :id,
    :timestamp,
    :duration,
    :visual,
    :narration,
    :status,
    :video_url,
    :thumbnail_url,
    keyword_init: true
  )

  Lesson = Struct.new(
    :id,
    :title,
    :description,
    :duration,
    :lesson_type,
    :rating,
    :video_streaming_source,
    :local_contents,  # Array<ContentStudio::LocalContent>
    :scenes,          # Array<ContentStudio::Scene>
    keyword_init: true
  )

  CourseModule = Struct.new(
    :id,
    :title,
    :lessons_count,
    :quizzes_count,
    :lessons,         # Array<ContentStudio::Lesson>
    keyword_init: true
  )

  Course = Struct.new(
    :id,
    :title,
    :description,
    :status,
    :visibility,
    :duration,
    :rating,
    :banner,
    :categories,
    :level,
    :levels,
    :course_modules_count,
    :enrollments_count,
    :team_enrollments_count,
    :modules,         # Array<ContentStudio::CourseModule>
    :progress,        # Integer 0–100 or nil
    :thumbnail_url,
    :created_at,
    keyword_init: true
  )

  CourseStats = Struct.new(:created, :published, :in_progress, keyword_init: true)

  CourseStructure = Struct.new(
    :id, :title, :duration, :modules, :verified_modules_count, :thumbnail_url, :progress_text, :stage, :saved,
    keyword_init: true
  ) do
    def script_writer_done?
      stage.to_s.start_with?('scene_writer_', 'generate_background_media', 'video_generation', 'log_course')
    end
  end

  StructureModule = Struct.new(:id, :title, :lessons, keyword_init: true)

  StructureLesson = Struct.new(:id, :title, :description, :summary, :estimated_duration, :status, :video_url, :verified,
                               :scenes, keyword_init: true)

  GenerationStatus = Struct.new(:status, :stage, :redirect_url, keyword_init: true)

  CourseMetadata = Struct.new(:categories, :languages, keyword_init: true)

  Avatar = Struct.new(:id, :name, :image_url, keyword_init: true)

  VideoTemplate = Struct.new(:id, :name, :thumbnail_url, keyword_init: true)

  User = Struct.new(
    :id,
    :name,
    :email,
    :role,
    keyword_init: true
  )

  Kit = Struct.new(
    :id,
    :title,
    :status,
    :stage,
    :thumbnail_url,
    :doc_count,
    :created_at,
    :updated_at,
    :expires_at,
    :components,
    :saved,
    keyword_init: true
  )

  KitComponent = Struct.new(
    :id,
    :type,
    :title,
    :status,
    :download_url,
    keyword_init: true
  )
end
