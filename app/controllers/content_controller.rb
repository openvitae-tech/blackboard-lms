# frozen_string_literal: true

class ContentController < ApplicationController
  def index
    authorize :content, :index?
    lp_id = current_user.learning_partner_id
    if policy(:course).manage?
      @courses_published_count = Course.where(learning_partner_id: lp_id).published.count
      @courses_unpublished_count = Course.where(learning_partner_id: lp_id, is_published: false).count
    end
    @programs_count = Program.where(learning_partner_id: lp_id).count
    @classroom_kits_count = ClassroomKit.where(learning_partner_id: lp_id).count if policy(:classroom_kit).index?
  end
end
