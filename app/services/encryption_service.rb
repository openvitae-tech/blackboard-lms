# frozen_string_literal: true

class EncryptionService
  SALT = 'common encryption'
  ENCRYPTOR = ActiveSupport::MessageEncryptor.new(
    Rails.application.key_generator.generate_key(SALT, ActiveSupport::MessageEncryptor.key_len)
  )

  def self.encrypt(value)
    ENCRYPTOR.encrypt_and_sign(value)
  end

  def self.decrypt(value)
    ENCRYPTOR.decrypt_and_verify(value)
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end
