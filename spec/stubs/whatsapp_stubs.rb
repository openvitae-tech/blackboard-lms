# frozen_string_literal: true

def stub_whatsapp_api(mobile_number, template)
  stub_request(
    :post,
    Rails.application.credentials.dig(:whatsapp, :url)
  ).with(
    headers: {
      'Authorization' => "Bearer #{Rails.application.credentials.dig(:whatsapp, :auth_token)}",
      'Content-Type' => 'application/json'
    },
    body: {
      'messaging_product' => 'whatsapp',
      'to' => mobile_number,
      'type' => 'template',
      'template' => {
        'name' => template,
        'language' => { 'code' => 'en' }
      }
    }
  ).to_return(
    status: 200, body: '', headers: {}
  )
end
