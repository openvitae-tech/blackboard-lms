# frozen_string_literal: true

def stub_msg91_sms_api(mobile_number, variables_values, template_id)
  stub_request(
    :post,
    Rails.application.credentials.dig(:msg91, :url)
  ).with(
    headers: {
      'authkey' => Rails.application.credentials.dig(:msg91, :auth_key),
      'accept' => 'application/json',
      'Content-Type' => 'application/json'
    },
    body: {
      'template_id' => template_id,
      'recipients' => [
        {
          'mobiles' => mobile_number
        }
      ],
      **variables_values
    }.to_json
  ).to_return(
    status: 200,
    body: '{"message": "success"}'
  )
end
