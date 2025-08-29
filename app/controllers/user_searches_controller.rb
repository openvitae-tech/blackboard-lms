# frozen_string_literal: true

class UserSearchesController < ApplicationController
  def index
    load_users
  end

  def create
    load_users
  end

  private

  def load_users
    @team = Team.find(search_params[:team_id])
    @all_members = search_params[:all_members] == 'true'
    @term = search_params[:term]
    per_page = @all_members ? 10 : 5
    @users = Users::FilterService.new(@team, term: @term, all_members: @all_members)
                                 .filter.page(params[:page]).per(per_page)
  end

  def search_params
    params.except(:authenticity_token).permit(:term, :team_id, :all_members)
  end
end