# frozen_string_literal: true

class Ui::IconsController < Ui::BaseController
  def index
    @icons = Dir.entries(Rails.root.join("app/assets/icons"))
                .select { |name| name.end_with?('.svg')}
                .map { |name| name.sub(".svg", "")}
  end
end