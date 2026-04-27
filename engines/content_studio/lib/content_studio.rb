# frozen_string_literal: true

require 'content_studio/version'
require 'content_studio/engine'
require 'content_studio/types'
require 'content_studio/blackboard_client'
require 'content_studio/neo_ai_client'
require 'content_studio/api_client'

module ContentStudio
  mattr_accessor :base_url, default: 'http://localhost:3000'
  mattr_accessor :public_host, default: 'http://localhost:3001'
  mattr_accessor :parent_controller, default: 'ActionController::Base'
  mattr_accessor :authorization_callback, default: ->(_user) { true }
end
