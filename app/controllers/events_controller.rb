# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @events = Event.order('id desc').all
  end
end
