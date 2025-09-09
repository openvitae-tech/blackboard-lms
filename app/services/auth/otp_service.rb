# frozen_string_literal: true

module Auth
  class OtpService
    MAX_ATTEMPTS = 2

    def initialize(phone, name: nil)
      @phone = phone
      @name = name
      @data = {}
    end

    def cache_key
      "otp:#{@phone.value}"
    end

    def generate_otp
      return false unless @phone.valid?

      read_previous_otp_data

      if @data.empty?
        # send new otp
        otp = Rails.env.production? ? rand(1000..9999) : User::TEST_OTP
        @data = { otp: otp, name: @name, attempts: 1 }.with_indifferent_access
        Rails.cache.write(cache_key, @data.to_json, expires_in: 5.minutes)
        send_otp(otp)
        true
      elsif @data[:attempts] < 2
        # resend old otp
        @data[:attempts] += 1
        Rails.cache.write(cache_key, @data.to_json, expires_in: 5.minutes)
        send_otp(@data[:otp])
        true
      else
        false
      end
    end

    def verify_otp(otp)
      return false unless @phone.valid?

      read_previous_otp_data
      return false unless @data[:otp].to_s == otp.to_s

      Rails.cache.delete(cache_key)
      write_contact!
    end

    private

    def read_previous_otp_data
      return @data if @data.present?

      previous_otp_data = Rails.cache.read(cache_key)
      if previous_otp_data.present?
        @data = JSON.parse(previous_otp_data)
        @data = @data.with_indifferent_access
        @name = @data[:name]
      end

      @data
    end

    def send_otp(otp)
      return unless Rails.env.production?

      template = ChannelMessageTemplates.instance.b2c_user_verify_template
      parameters = { sms_variables_values: { 'var1' => otp.to_s } }
      # Verify only indian numbers
      UserChannelNotifierService.instance.notify_via_sms(
        template,
        AVAILABLE_COUNTRIES[:india][:code],
        @phone.value,
        parameters
      )
    end

    def write_contact!
      ContactLead.create!(name: @name, phone: @phone.value, country_code: @phone.country_code)
    end
  end
end
