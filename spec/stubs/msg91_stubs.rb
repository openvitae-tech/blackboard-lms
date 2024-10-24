# frozen_string_literal: true

def stub_msg91_sms_api(mobile_number, otp)
  stub_request(
    :post,
    'https://control.msg91.com/api/v5/flow'
  ).with(
    headers: {
      'authkey' => Rails.application.credentials.dig(:msg91, :auth_key),
      'accept' => 'application/json',
      'Content-Type' => 'application/json'
    },
    body: {
      'template_id' => Rails.application.credentials.dig(:msg91, :template_id),
      'recipients' => [
        {
          'mobiles' => mobile_number
        }
      ],
      'OTP' => otp
    }.to_json
  ).to_return(
    status: 200,
    body: '{"message": "success"}'
  )
end
