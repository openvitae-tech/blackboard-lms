# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  def index
    authorize :dashboard
  end
end
