# frozen_string_literal: true

class UserSearchesController < ApplicationController
  def create
    @team = Team.find(search_params[:team_id])
    @users = Users::FilterService.new(search_params).filter.includes([:team]).page(params[:page]).per(5)
  end

  def search_params
    params.except(:authenticity_token).permit(:term, :team_id)
  end
end