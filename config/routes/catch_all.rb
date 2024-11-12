# frozen_string_literal: true

Rails.application.routes.draw do
  match ':url', to: 'application#not_found', via: :all, url: /.*/, constraints: lambda { |request|
    request.path.exclude?('/rails/')
  }
end
