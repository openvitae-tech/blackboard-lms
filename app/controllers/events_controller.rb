class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  def index
    @partners = LearningPartner.all
    @events = Event.all
  end
end
