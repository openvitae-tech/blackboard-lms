class Lesson::RatingsController < ApplicationController
  before_action :set_course
  before_action :set_course_module
  before_action :set_lesson

  def new
    authorize @lesson, policy_class: LessonRatingPolicy
  end

  def create
    authorize @lesson, policy_class: LessonRatingPolicy

    service = Lessons::RatingService.instance
    service.rate_lesson!(current_user, @lesson, rating_params[:value].to_f)
  end

  private

  def rating_params
    params.require(:lesson_rating).permit(:value)
  end

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_course_module
    @course_module = @course.course_modules.find(params[:module_id])
  end

  def set_lesson
    @lesson = @course_module.lessons.find(params[:lesson_id])
  end
end
