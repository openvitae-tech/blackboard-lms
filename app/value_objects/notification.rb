# frozen_string_literal: true

# PORO class for Notification
class Notification
  VALID_TYPES = %w[info error].freeze

  attr_accessor :user, :title, :text, :ntype, :timestamp, :link

  def initialize(user, title, text, link: nil, ntype: 'info', timestamp: Time.zone.now.to_i)
    @user = user
    @title = title
    @text = text
    @link = link
    @ntype = ntype
    @timestamp = timestamp

    raise Errors::InvalidNotificationType, "Invalid notification type #{ntype}" unless VALID_TYPES.include? ntype
  end

  def to_json(*_args)
    {
      title:,
      text:,
      link:,
      ntype:,
      timestamp:
    }.to_json
  end

  def created_at
    Time.zone.at(timestamp)
  end

  def encoded_message
    CGI.escape(Base64.encode64(to_json))
  end
end
