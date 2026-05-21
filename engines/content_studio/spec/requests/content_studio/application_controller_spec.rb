# frozen_string_literal: true

require_relative '../../rails_helper'

RSpec.describe 'ContentStudio::ApplicationController', type: :request do
  describe 'unauthorized access' do
    before do
      allow(ContentStudio).to receive(:authorization_callback).and_return(->(_user) { false })
      get '/content_studio'
    end

    it 'redirects to /' do
      expect(response).to redirect_to('/')
    end
  end
end
