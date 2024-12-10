# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :authenticate_user!

  before_action :load_tag, only: [:edit, :show, :update, :destroy]
  def new
    @tag = Tag.new
  end

  def index
    @tags = Tag.page(filter_params[:page]).per(9).order(created_at: :desc)
    @tags_count = Tag.count
  end

  def show
    render
  end

  def create
    @tag = Tag.create!(tag_params)
    @tags_count = Tag.count
  end

  def edit
    render
  end

  def update
    @tag.update!(tag_params)
  end

  def destroy
    @tag.destroy!
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
