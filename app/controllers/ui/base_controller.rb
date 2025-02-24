# frozen_string_literal: true

class Ui::BaseController < ApplicationController
  before_action :authenticate_admin!
end