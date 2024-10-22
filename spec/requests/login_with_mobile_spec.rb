# frozen_string_literal: true

RSpec.describe 'Login with mobile number' do
  describe 'GET /logins/new' do
    it 'renders the login with mobile page' do
      get '/logins/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /logins/otp' do
    it 'requests otp for the give mobile number and renders the otp page' do
      user = create :user, :learner
      post '/logins/otp', params: { login: { mobile_number: user.phone } }
      expect(response).to render_template(:otp)
      user.reload
      expect(user.otp).to eq(User::TEST_OTP)
      expect(user.otp_generated_at).not_to be_nil
    end

    it 'redirects the user to login screen if the mobile number is invalid' do
      create :user, :learner
      post '/logins/otp', params: { login: { mobile_number: Faker::Number.number(digits: 10) } }
      expect(response).to redirect_to('/logins/new')
    end
  end

  describe 'POST /logins' do
    it 'creates a successful login if the otp is a match' do
      user = create :user, :learner
      user.set_otp!
      post '/logins', params: { login: { mobile_number: user.phone, otp: user.otp } }
      expect(response).to redirect_to('/courses')
    end

    it 'redirects to login page if the otp is a mismatch' do
      user = create :user, :learner
      user.set_otp!
      post '/logins', params: { login: { mobile_number: user.phone, otp: '1234' } }
      expect(response).to redirect_to('/logins/new')
    end
  end
end
