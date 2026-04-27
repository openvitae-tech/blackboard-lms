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
    :scenes,          # Array<ContentStudio::Scene> — populated by NeoAiClient
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
    :is_published,
    :duration,
    :rating,
    :banner,
    :categories,
    :levels,
    :course_modules_count,
    :enrollments_count,
    :team_enrollments_count,
    :modules,         # Array<ContentStudio::CourseModule>
    :progress,        # Integer 0–100 or nil
    :thumbnail_url,
    keyword_init: true
  )

  CourseStats = Struct.new(:created, :published, :in_progress, keyword_init: true)

  CourseStructure = Struct.new(
    :id, :title, :duration, :modules, :verified_modules_count, :thumbnail_url, :progress_text, :stage,
    keyword_init: true
  )

  StructureModule = Struct.new(:id, :title, :lessons, keyword_init: true)

  StructureLesson = Struct.new(:id, :title, :description, :summary, :estimated_duration, :status, :video_url, :scenes,
                               keyword_init: true)

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
end
