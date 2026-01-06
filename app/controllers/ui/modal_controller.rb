# frozen_string_literal: true

class Ui::ModalController < Ui::BaseController
  def index
  end

  def preview
    render partial: "ui/modal/sample_modal"
  end
  
  def success_modal
    render partial: "ui/modal/success_modal"
  end

  def footer_modal
    render partial: "ui/modal/footer_modal"
  end
end
