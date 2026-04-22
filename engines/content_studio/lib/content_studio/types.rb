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

  Lesson = Struct.new(
    :id,
    :title,
    :description,
    :duration,
    :lesson_type,
    :rating,
    :video_streaming_source,
    :local_contents,  # Array<ContentStudio::LocalContent>
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
    keyword_init: true
  )

  CourseStats = Struct.new(:created, :published, :in_progress, keyword_init: true)

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
