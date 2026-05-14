require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.active_storage.service = :local
  config.hosts << 'kosher-alienable-confusing.ngrok-free.dev'
  config.enable_reloading = true
  config.file_watcher = ActiveSupport::FileUpdateChecker
  config.assets.quiet = true
  config.assets.compile = true
  config.assets.debug = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true
  config.cache_store = :memory_store
  config.active_support.deprecation = :log
  config.action_view.annotate_rendered_view_with_filenames = true
  config.action_controller.raise_on_missing_callback_actions = true
end
