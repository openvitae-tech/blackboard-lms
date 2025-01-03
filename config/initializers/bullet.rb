# frozen_string_literal: true

if Rails.env.local? && defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true

  Bullet.rails_logger = true
  Bullet.raise = true if Rails.env.test?

  Bullet.n_plus_one_query_enable = true
  Bullet.unused_eager_loading_enable = true
  Bullet.counter_cache_enable = true
end
