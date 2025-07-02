# frozen_string_literal: true
class SearchesController < ApplicationController
  before_action :build_search_context, only: :index

  def index
    service = Courses::FilterService.instance
    @search_context = build_search_context
    @courses = service.filter(current_user, @search_context)
  end

  private

  def search_params
    params.require(:search).permit(:context, :team_id, :user_id, :term, :tags)
  end

  def build_search_context
    options = {}

    case params[:context]
    when 'team_assign' then
      @team = Team.find params[:team_id]
      options[:team] = @team
    when 'user_assign' then
      @user = User.find params[:user_id]
      options[:user] = @user
    end

    SearchContext.new(
      context: params[:context],
      term: params[:term],
      tags: params[:tags],
      options:
    )
  end
end