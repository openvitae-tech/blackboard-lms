# frozen_string_literal: true

module CourseJson
  extend ActiveSupport::Concern

  def to_json_data
    course_data = set_course_data_attributes
    course_data['modules'] = []

    modules_in_order.each do |course_module|
      module_data = set_module_data_attributes(course_module)
      module_data['lessons'] = []

      course_module.lessons_in_order.each do |lesson|
        lesson_data = set_lesson_data_attributes(lesson)
        lesson_data['local_contents'] = []

        lesson.local_contents.each do |local_content|
          local_content_data = set_local_content_data_attributes(local_content)
          lesson_data['local_contents'].push(local_content_data)
        end

        module_data['lessons'].push(lesson_data)
      end

      course_data['modules'].push(module_data)
    end

    course_data.to_json
  end

  private

  def set_course_data_attributes
    course_data = {}
    course_data['id'] = id
    course_data['categories'] = tags.filter { |t| t.tag_type == 'category' }.map(&:name)
    course_data['course_modules_count'] = course_modules_count
    course_data['created_at'] = created_at
    course_data['description'] = description
    course_data['duration'] = duration
    course_data['enrollments_count'] = enrollments_count
    course_data['id'] = id
    course_data['is_published'] = is_published
    course_data['levels'] = tags.filter { |t| t.tag_type == 'level' }.map(&:name)
    course_data['rating'] = rating
    course_data['team_enrollments_count'] = team_enrollments_count
    course_data['title'] = title
    course_data['updated_at'] = updated_at
    course_data['visibility'] = visibility
    course_data['banner'] = ''
    course_data
  end

  def set_module_data_attributes(course_module)
    module_data = {}
    module_data['id'] = course_module.id
    module_data['created_at'] = course_module.created_at
    module_data['lessons_count'] = course_module.lessons_count
    module_data['quizzes_count'] = course_module.quizzes_count
    module_data['title'] = course_module.title
    module_data['updated_at'] = course_module.updated_at
    module_data
  end

  def set_lesson_data_attributes(lesson)
    lesson_data = {}
    lesson_data['id'] = lesson.id
    lesson_data['created_at'] = lesson.created_at
    lesson_data['description'] = lesson.description
    lesson_data['duration'] = lesson.duration
    lesson_data['last_rated_at'] = lesson.last_rated_at
    lesson_data['lesson_type'] = lesson.lesson_type
    lesson_data['rating'] = lesson.rating
    lesson_data['title'] = lesson.title
    lesson_data['updated_at'] = lesson.updated_at
    lesson_data['video_streaming_source'] = lesson.video_streaming_source
    lesson_data
  end

  def set_local_content_data_attributes(local_content)
    local_content_data = {}
    local_content_data['id'] = local_content.id
    local_content_data['lang'] = local_content.lang
    local_content_data['status'] = local_content.status
    local_content_data['video_published_at'] = local_content.video_published_at
    local_content_data['video_url'] = local_content.video_url
    local_content_data
  end
end
