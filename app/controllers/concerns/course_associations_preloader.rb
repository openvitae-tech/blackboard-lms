module CourseAssociationsPreloader
  extend ActiveSupport::Concern

  private

  def preload_course_associations
    available_courses = []
    enrolled_courses  = []

    if @type.nil? || @type == "all"
      available_courses = @available_courses.present? ? @available_courses.to_a : []
    end

    if @type.nil? || @type == "enrolled"
      enrolled_courses = @enrolled_courses.present? ? @enrolled_courses.to_a : []
    end

    records = available_courses + enrolled_courses
    return if records.empty?

    ActiveRecord::Associations::Preloader.new(
      records: records,
      associations: [ :banner_attachment, :tags ]
    ).call


    if enrolled_courses.any?
      ActiveRecord::Associations::Preloader.new(
        records: enrolled_courses,
        associations: :course_modules
      ).call
    end
  end
end
