class CourseModulesController < ApplicationController
  before_action :set_course, only: %i[new create show edit update destroy]
  before_action :set_course_module, only: %i[show edit update destroy]
  # GET /course_modules/1 or /course_modules/1.json
  def show
    @lessons = helpers.lessons_in_order(@course_module)
    @quizzes = helpers.quizzes_in_order(@course_module)
    @enrollment = current_user.get_enrollment_for(@course) if current_user.enrolled_for_course?(@course)
  end

  # GET /course_modules/new
  def new
    @course_module = @course.course_modules.new
  end

  # GET /course_modules/1/edit
  def edit
  end

  # POST /course_modules or /course_modules.json
  def create
    @course_module = @course.course_modules.new(course_module_params)
    service = CourseManagementService.instance
    service.set_module_attributes(@course, @course_module)
    service.update_module_ordering(@course, @course_module, :destroy)

    respond_to do |format|
      if @course_module.save
        format.html { redirect_to course_url(@course), notice: "Course module was successfully created." }
        format.json { render :show, status: :created, location: @course_module }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_modules/1 or /course_modules/1.json
  def update
    respond_to do |format|
      if @course_module.update(course_module_params)
        format.html { redirect_to course_module_url(@course, @course_module), notice: "Course module was successfully updated." }
        format.json { render :show, status: :ok, location: @course_module }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course_module.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_modules/1 or /course_modules/1.json
  def destroy
    @course_module.destroy!
    service = CourseManagementService.instance
    service.update_module_ordering(@course, @course_module, :destroy)

    respond_to do |format|
      format.html { redirect_to course_url(@course), notice: "Course module was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_module
      @course_module = @course.course_modules.find(params[:id])
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

  # Only allow a list of trusted parameters through.
    def course_module_params
      params.require(:course_module).permit(:title, :description)
    end
end
