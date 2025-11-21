# frozen_string_literal: true

class Ui::ModalController < Ui::BaseController
  def index
  end

  def preview
    render partial: "ui/modal/sample_modal"
  end
end
