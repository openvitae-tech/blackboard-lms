class Commons::AlertModalController < ApplicationController
  def show
    @title = params[:title]
    @description = params[:description]
    @method = params[:method]
    @action_path = params[:action_path]
  end
end
