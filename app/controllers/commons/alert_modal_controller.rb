class Commons::AlertModalController < ApplicationController
  def show
    @title = params[:title]
    @description = params[:description]
    @method = params[:method]
    @action_path = params[:action_path]
    @action_text = params[:action_text] || I18n.t(@method == 'delete' ? 'button.delete' : 'button.ok')
    @action_type = params[:action_type] || (@method == 'delete' ? 'danger' : 'primary')
  end
end
