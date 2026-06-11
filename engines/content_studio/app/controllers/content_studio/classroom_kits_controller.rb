# frozen_string_literal: true

module ContentStudio
  class ClassroomKitsController < ApplicationController
    def new
      redirect_to new_classroom_kit_path
    end
  end
end
