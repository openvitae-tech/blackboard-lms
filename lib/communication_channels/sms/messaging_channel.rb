# frozen_string_literal: true

module CommunicationChannels
  module Sms
    class MessagingChannel < CommunicationChannels::MessagingChannelBase
      def send_message(mobile_number, variables_values, template_id)
        return if template_id.blank?

        response = dispatch_sms_request(mobile_number, variables_values, template_id)
        log_error_to_sentry(response) unless response.is_a?(Net::HTTPSuccess)
        response
      rescue StandardError
        log_general_error(mobile_number)
      end

      private

      def dispatch_sms_request(mobile_number, variables_values, template_id)
        url = URI.parse(Rails.application.credentials.dig(:fast2sms, :url))
        request = build_request_url(url, mobile_number, variables_values, template_id)
        Net::HTTP.start(url.hostname, url.port, use_ssl: true, read_timeout: 1) { |http| http.request(request) }
      end

      def build_request_url(url, mobile_number, variables_values, template_id)
        request = Net::HTTP::Post.new(url)
        request['authorization'] = Rails.application.credentials.dig(:fast2sms, :auth_key)
        request['Content-Type'] = 'application/json'

        request.set_form_data({
                                'route' => 'dlt',
                                'sender_id' => Rails.application.credentials.dig(:fast2sms, :sender_id),
                                'message' => template_id,
                                'variables_values' => variables_values,
                                'numbers' => mobile_number
                              })

        request
      end

      def log_error_to_sentry(response)
        Sentry.capture_message('Failed to send OTP via SMS', level: :error, extra: {
                                 status: response.code,
                                 body: response.body
                               })
      end

      def log_general_error(mobile_number)
        Sentry.capture_message('An error occurred while sending OTP', level: :warning, extra: {
                                 mobile_number:
                               })
      end
    end
  end
end
