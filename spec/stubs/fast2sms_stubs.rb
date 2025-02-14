# frozen_string_literal: true

def stub_fast2sms_api(mobile_number, otp)
  stub_request(
    :post,
    'https://www.fast2sms.com/dev/bulkV2'
  ).with(
    headers: {
      'authorization' => Rails.application.credentials.dig(:fast2sms, :auth_key),
      'Content-Type' => 'application/x-www-form-urlencoded'
    },
    body: {
      'message' => Rails.application.credentials.dig(:fast2sms, :message_id),
      'numbers' => mobile_number,
      'route' => 'dlt',
      'sender_id' => Rails.application.credentials.dig(:fast2sms, :sender_id),
      'variables_values' => otp.to_s
    }
  ).to_return(
    status: 200, body: '', headers: {}
  )
end
