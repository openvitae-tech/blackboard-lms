# frozen_string_literal: true

class SettingsController < ApplicationController
  def index
    authorize :setting
  end
end
