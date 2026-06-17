# frozen_string_literal: true

class ContentController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize :content, :index?
    lp_id = current_user.learning_partner_id
    if policy(:course).manage?
      @courses_published_count = Course.where(learning_partner_id: lp_id).published.count
      @courses_unpublished_count = Course.where(learning_partner_id: lp_id, is_published: false).count
    end
    @programs_count = Program.where(learning_partner_id: lp_id).count
  end
end
