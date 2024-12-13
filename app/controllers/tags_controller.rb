# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :authenticate_user!

  before_action :load_tag, only: [:edit, :show, :update, :destroy]
  def new
    authorize :tag
    @tag = Tag.new
  end

  def index
    authorize :tag
    @tags = Tag.page(filter_params[:page]).per(Tag::DEFAULT_PER_PAGE_SIZE).order(created_at: :desc)
    @tags_count = Tag.count
  end

  def show
    authorize @tag
  end

  def create
    authorize :tag
    @tag = Tag.create!(tag_params)
    @tags_count = Tag.count
    flash.now[:success] = t("resource.created", resource_name: "Tag")

  rescue ActiveRecord::RecordInvalid => exception
    @tag = exception.record
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize @tag
    @type = @tag.tag_type
  end

  def update
    authorize @tag
    @tag.update!(tag_params)
    flash.now[:success] = t("resource.updated", resource_name: "Tag")
  rescue ActiveRecord::RecordInvalid => exception
    @tag = exception.record
    render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @tag
    @tag.destroy!
    flash.now[:success] = t("resource.deleted", resource_name: "Tag")
    @tags_count = Tag.count
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :tag_type)
  end

  def filter_params
    params.permit(:page)
  end

  def load_tag
    @tag = Tag.find(params[:id])
  end
end
