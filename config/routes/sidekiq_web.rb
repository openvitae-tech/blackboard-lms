# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  def _secure_compare(sig1, sig2)
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(sig1), Digest::SHA256.hexdigest(sig2))
  end

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      _secure_compare(username,
                      'sidekiq') & _secure_compare(password, Rails.application.credentials.dig(:sidekiq, :password))
    end
  end

  if Rails.env.development?
    mount Sidekiq::Web, at: '/sidekiq'
  else
    mount Sidekiq::Web, at: '/sidekiq', constraints: { method: 'GET' }
  end
end
