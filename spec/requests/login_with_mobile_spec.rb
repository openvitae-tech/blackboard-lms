# frozen_string_literal: true

RSpec.describe 'Login with mobile number' do
  let(:user) { create :user, :learner, state: 'unverified' }

  describe 'GET /login/new' do
    it 'renders the login with mobile page' do
      get '/login/new'
      expect(response).to render_template(:new)
    end
  end

  describe 'POST /login/otp' do
    it 'requests otp for the give mobile number and renders the otp page' do
      post '/login/otp', params: { login: { mobile_number: user.phone, country_code: user.country_code } }
      expect(user.otp).to be_nil
      expect(response).to render_template(:otp)

      user.reload
      expect(user.otp).not_to be_nil
      expect(user.otp_generated_at).not_to be_nil
    end

    it 'redirects the user to login screen if the mobile number is invalid' do
      post '/login/otp',
           params: { login: { mobile_number: Faker::Number.number(digits: 10), country_code: user.country_code } }
      expect(response).to redirect_to('/login/new')
    end
  end

  describe 'POST /login' do
    it 'creates a successful login if the otp is a match' do
      user.set_otp!
      post '/login',
           params: { login: { mobile_number: user.phone, country_code: user.country_code,
                              otp: password_decrypter(user.otp) } }
      expect(response).to redirect_to('/courses')
    end

    it 'Mark the user as verified for the first time login using otp' do
      expect(user).to be_unverified
      user.set_otp!
      post '/login',
           params: { login: { mobile_number: user.phone, country_code: user.country_code,
                              otp: password_decrypter(user.otp) } }
      expect(user.reload).to be_verified
    end

    it 'when otp is a mismatch' do
      user.set_otp!
      post '/login', params: { login: { mobile_number: user.phone, country_code: user.country_code, otp: '1234' } }

      expect(flash[:error]).to eq(t('login.invalid_or_incorrect_otp'))
      expect(response.status).to be(404)
    end
  end

  private

  def password_decrypter(otp)
    password_verifier = Rails.application.message_verifier(Rails.application.credentials[:password_verifier])

    password_verifier.verify(otp)
  end
end
