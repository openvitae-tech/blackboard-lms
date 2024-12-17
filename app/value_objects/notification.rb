# frozen_string_literal: true

# PORO class for Notification
class Notification
  VALID_TYPES = %w[info error]

  attr_accessor :user, :text, :ntype, :timestamp

  def initialize(user, text, ntype: 'info', timestamp: Time.zone.now.to_i)
    @user = user
    @text = text
    @ntype = ntype
    @timestamp = timestamp

    raise Errors::InvalidNotificationType.new("Invalid notification type #{ntype}") unless VALID_TYPES.include? ntype
  end

  def to_json
    {
      text: self.text,
      ntype: self.ntype,
      timestamp: self.timestamp
    }.to_json
  end

  def created_at
    Time.at(self.timestamp)
  end

  def encoded_message
    CGI.escape(Base64.encode64(to_json))
  end
end