# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :set_tag, only: [:edit, :update, :destroy]

  def new
    authorize :tag
    @tag = Tag.new
  end

  def index
    authorize :tag
    @tags = Tag.page(filter_params[:page]).per(Tag::DEFAULT_PER_PAGE_SIZE).order(created_at: :desc)
    @tags_count = Tag.count
  end

  def create
    authorize :tag
    @tag = Tag.new(tag_params)
    if @tag.save
      @tags_count = Tag.count
      flash.now[:success] = t("resource.created", resource_name: "Tag")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @tag
    @type = @tag.tag_type
  end

  def update
    authorize @tag
    if @tag.update(tag_params)
      flash.now[:success] = t("resource.updated", resource_name: "Tag")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @tag
    @tag.destroy!
    flash.now[:success] = t("resource.deleted", resource_name: "Tag")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.redirect_to(tags_path(page: get_current_page(params[:page])))
      end
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :tag_type)
  end

  def filter_params
    params.permit(:page)
  end

  def set_tag
    @tag = Tag.find(params[:id])
  end

  def get_current_page(page)
    current_page = page.to_i
    current_page = 1 if current_page.zero?

    tags = Tag.page(current_page).per(Tag::DEFAULT_PER_PAGE_SIZE)
    if tags.empty? && current_page > 1
      new_page = current_page - 1
    else
      new_page = current_page
    end
    new_page
  end
end
