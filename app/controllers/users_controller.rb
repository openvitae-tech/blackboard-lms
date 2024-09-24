# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update destroy]

  # GET /users or /users.json
  def index
    authorize User
    if current_user.is_admin?
      @users = User.includes(:learning_partner).order(:name).page(params[:page])
    elsif current_user.is_manager? || current_user.is_owner?
      @users = User.includes(:learning_partner)
                   .where.not(role: 'admin')
                   .order(:name).page(params[:page])
    end
  end

  # GET /users/1 or /users/1.json
  def show
    authorize @user
  end

  # GET /users/new
  def new
    authorize User
    if params[:partner_id].present?
      @partner = LearningPartner.find(params[:partner_id])
    else
      @partner_list = LearningPartner.all
    end

    @user = User.new
  end

  # GET /users/1/edit
  def edit
    authorize @user
    @partner_list = LearningPartner.all
  end

  # POST /users or /users.json
  def create
    authorize User
    @user = User.new(user_params)
    @user.set_temp_password

    respond_to do |format|
      if @user.save
        format.html { redirect_to user_url(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    authorize @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    authorize @user
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:name, :role, :email, :learning_partner_id)
  end
end
