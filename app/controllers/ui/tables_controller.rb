# frozen_string_literal: true

class Ui::TablesController < Ui::BaseController
  def index
    @tags = Tag.load_tags
    @learning_partners = LearningPartner.all
  end
end