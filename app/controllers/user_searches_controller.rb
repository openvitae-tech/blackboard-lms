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
    @all_members = search_params[:all_members]
    @team = Team.find(search_params[:team_id])
    @users = Users::FilterService.new(@team, term: search_params[:term], all_members: @all_members)
                                 .filter.includes([:team]).page(params[:page]).per(5)
  end

  def search_params
    params.except(:authenticity_token).permit(:term, :team_id, :all_members)
  end
end