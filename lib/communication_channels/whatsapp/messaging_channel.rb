# frozen_string_literal: true

module CommunicationChannels
  module Whatsapp
    class MessagingChannel < CommunicationChannels::MessagingChannelBase
      def send_message(mobile_number, template_name, parameters = nil)
        return if mobile_number.empty? || template_name.empty?

        response = send_request(mobile_number, template_name, parameters)

        return response if response.is_a?(Net::HTTPSuccess)

        log_error_to_sentry(response, 'Failed to send whatsapp message')
      end

      private

      def send_request(mobile_number, template_name, parameters)
        url = URI.parse(Rails.application.credentials.dig(:whatsapp, :url))
        request = build_request(url, mobile_number, template_name, parameters)
        Net::HTTP.start(url.hostname, url.port, use_ssl: true, read_timeout: 2) { |http| http.request(request) }
      end

      def build_request(url, mobile_number, template_name, parameters)
        request = Net::HTTP::Post.new(url)
        request['Authorization'] =
          "Bearer #{Rails.application.credentials.dig(:whatsapp, :auth_token)}"
        request['Content-Type'] = 'application/json'

        body = {
          messaging_product: 'whatsapp',
          to: mobile_number,
          type: 'template',
          template: {
            name: template_name,
            language: {
              code: 'en'
            }
          }
        }

        if parameters.present?
          body[:template][:components] = [
            {
              type: 'body',
              parameters:
            }
          ]
        end

        request.body = body.to_json
        request
      end

      def log_error_to_sentry(response, msg)
        Sentry.capture_message(msg, level: :error, extra: {
                                 status: response.code,
                                 body: response.body
                               })
      end
    end
  end
end
