# frozen_string_literal: true

module CommunicationChannels
  module Sms
    class Msg91MessagingChannel < CommunicationChannels::MessagingChannelBase
      def send_message(mobile_number, variables_values, template_id)
        return if template_id.blank?

        response = dispatch_sms_request(mobile_number, variables_values, template_id)
        log_error_to_sentry(response) unless response.is_a?(Net::HTTPSuccess)
        response
      rescue StandardError
        log_general_error(mobile_number)
      end

      def get_template_id(template)
        template['msg91']
      end

      private

      def dispatch_sms_request(mobile_number, variables_values, template_id)
        url = URI.parse(Rails.application.credentials.dig(:msg91, :url))
        request = build_request_url(url, mobile_number, variables_values, template_id)
        Net::HTTP.start(url.hostname, url.port, use_ssl: true, read_timeout: 1) { |http| http.request(request) }
      end

      def build_request_url(url, mobile_number, variables_values, template_id)
        request = Net::HTTP::Post.new(url)
        request['authkey'] = Rails.application.credentials.dig(:msg91, :auth_key)
        request['accept'] = 'application/json'
        request['Content-Type'] = 'application/json'

        request.body = {
          'template_id' => template_id,
          'recipients' => [
            {
              'mobiles' => mobile_number
            }
          ],
          **variables_values
        }.to_json

        request
      end

      def log_error_to_sentry(response)
        Sentry.capture_message('Failed to send SMS', level: :error, extra: {
                                 status: response.code,
                                 body: response.body
                               })
      end

      def log_general_error(mobile_number)
        Sentry.capture_message('An error occurred while sending SMS', level: :warning, extra: {
                                 mobile_number:
                               })
      end
    end
  end
end
