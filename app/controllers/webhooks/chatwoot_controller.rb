class Webhooks::ChatwootController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    account_id = Rails.application.credentials.dig(:chatwoot, :account_id)

    unless params.dig(:account, :id).to_s == account_id.to_s
      return head :unauthorized
    end

    message_type, sender_type = extract_message_data(params)

    return head :ok unless message_type == 'incoming' || sender_type == 'contact'

    chatwoot_service = Webhooks::ChatwootNotifierService.instance
    chatwoot_service.notify(params)

    head :ok
  end

  private


  def extract_message_data(params)
    message = params['message'] ||
              (params.dig('conversation', 'messages')&.first) ||
              params

    message_type = message['message_type'] || message.dig('message', 'message_type')
    sender_type  = (message.dig('sender', 'type') || message['sender_type'] || '').to_s.downcase

    [message_type, sender_type]
  end
end
