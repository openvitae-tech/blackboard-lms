# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show]

  def show
    authorize @user
  end

  private

    def set_user
      @user = User.find(params[:id])
      @enrolled_courses = @user.courses.includes(:enrollments)
    end
  end
