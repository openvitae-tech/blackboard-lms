# frozen_string_literal: true

if Rails.env.local? && defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true

  Bullet.rails_logger = true
  Bullet.raise = true

  Bullet.n_plus_one_query_enable = true
  Bullet.unused_eager_loading_enable = true
  Bullet.counter_cache_enable = true

  # Locally courses have no banners so blob appears unused, but in production
  # all courses have banners and blob is accessed for the S3 service name check.
  Bullet.add_safelist(type: :unused_eager_loading, class_name: 'ActiveStorage::Attachment', association: :blob)
end
