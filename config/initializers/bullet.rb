# frozen_string_literal: true

if Rails.env.local? && defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true

  Bullet.rails_logger = true
  Bullet.raise = true if Rails.env.test?

  Bullet.n_plus_one_query_enable = true
  Bullet.unused_eager_loading_enable = true
  Bullet.counter_cache_enable = true

  # ActiveStorage::Blob#touch_attachments internally calls includes(:record) so it can
  # touch the polymorphic owner. Bullet flags :record as unused because it doesn't
  # recognise touch as an attribute access. This is a false positive from Rails internals.
  Bullet.add_safelist(type: :unused_eager_loading, class_name: "ActiveStorage::Attachment", association: :record)
end
