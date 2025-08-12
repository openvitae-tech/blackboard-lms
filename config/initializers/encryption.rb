# frozen_string_literal: true

ENCRYPTION_KEY = Rails.application.key_generator.generate_key('default encryption',
                                                              ActiveSupport::MessageEncryptor.key_len)

DEFAULT_ENCRYPTOR = ActiveSupport::MessageEncryptor.new(ENCRYPTION_KEY)
