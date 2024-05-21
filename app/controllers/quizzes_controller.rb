class QuizzesController < ApplicationController
  before_action :set_course
  before_action :set_course_module
  before_action :set_quiz, only: %i[ show edit update destroy ]

  # GET /quizzes or /quizzes.json
  # GET /quizzes/1 or /quizzes/1.json
  def show
    @quizzes = @course_module.quizzes
  end

  # GET /quizzes/new
  def new
    @quiz = @course_module.quizzes.new
  end

  # GET /quizzes/1/edit
  def edit
  end

  # POST /quizzes or /quizzes.json
  def create
    @quiz = @course_module.quizzes.new(quiz_params)
    service = CourseManagementService.instance
    service.set_quiz_attributes(@course_module, @quiz)


    respond_to do |format|
      if @quiz.save
        format.html { redirect_to course_module_path(@course, @course_module), notice: "Quiz was successfully created." }
        format.json { render :show, status: :created, location: @quiz }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quizzes/1 or /quizzes/1.json
  def update
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to course_module_path(@course, @course_module), notice: "Quiz was successfully updated." }
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1 or /quizzes/1.json
  def destroy
    @quiz.destroy!

    respond_to do |format|
      format.html { redirect_to course_module_path(@course, @course_module), notice: "Quiz was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quiz
      @quiz = @course_module.quizzes.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def quiz_params
      params.require(:quiz).permit(:question, :option_a, :option_b, :option_c, :option_d, :answer)
    end

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_course_module
      @course_module = @course.course_modules.find(params[:module_id])
    end

    def set_lesson
      @quiz = @course_module.quizzes.find(params[:id])
    end
end
