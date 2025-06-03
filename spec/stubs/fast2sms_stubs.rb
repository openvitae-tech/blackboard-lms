# frozen_string_literal: true

def stub_fast2sms_api(mobile_number, variables_values, template_id)
  stub_request(
    :post,
    'https://www.fast2sms.com/dev/bulkV2'
  ).with(
    headers: {
      'authorization' => Rails.application.credentials.dig(:fast2sms, :auth_key),
      'Content-Type' => 'application/x-www-form-urlencoded'
    },
    body: {
      'message' => template_id,
      'numbers' => mobile_number,
      'route' => 'dlt',
      'sender_id' => Rails.application.credentials.dig(:fast2sms, :sender_id),
      'variables_values' => variables_values
    }
  ).to_return(
    status: 200, body: '', headers: {}
  )
end
