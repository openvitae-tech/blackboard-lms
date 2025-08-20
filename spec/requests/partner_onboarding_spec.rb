# frozen_string_literal: true

RSpec.describe 'Request spec for LearningPartner' do
  describe 'Listing partners -> GET /learning_partners' do
    before do
      admin_user = create :user, :admin
      sign_in admin_user
    end

    it 'Requires authentication' do
      user = create :user, :owner
      sign_out user
      get '/learning_partners'
      expect(response).to redirect_to(new_login_path)
    end

    it 'Forbids non admin user to list partners' do
      non_admin = create :user, :owner
      sign_in non_admin
      get '/learning_partners'
      follow_redirect!
      expect(response).to have_http_status(:unauthorized)
    end

    it 'Allows listing of all partners by an admin user' do
      partners = (1..3).map { |_| create :learning_partner }.sort_by(&:name)
      get '/learning_partners'
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:learning_partners)).to eq(partners)
    end
  end

  describe 'Onboarding partner -> POST /learning_partners' do
    before do
      admin_user = create :user, :admin
      sign_in admin_user
    end

    it 'Requires authentication' do
      user = create :user, :owner
      sign_out user
      post '/learning_partners'
      expect(response).to redirect_to(new_login_path)
    end

    it 'Forbids non admin user to create partners' do
      non_admin = create :user, :owner
      sign_in non_admin
      post '/learning_partners'
      follow_redirect!
      expect(response).to have_http_status(:unauthorized)
    end

    it 'Expects a mandatory partner name' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          about: partner.about
        }
      }
      post('/learning_partners', params:)
      expect(response).to have_http_status(:bad_request)
    end

    it 'Partner name should not be longer than 255 chars' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: 'a' * 256,
          about: partner.about
        }
      }
      post('/learning_partners', params:)
      expect(response).to have_http_status(:bad_request)
    end

    it 'Partner description should not be longer than 1024 chars' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: 'a' * 5000,
          supported_countries: partner.supported_countries
        }
      }
      post('/learning_partners', params:)
      expect(response).to have_http_status(302)
    end

    it 'Requires logo size to be less than 1 MB' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: partner.about,
          logo: big_image_file
        }
      }

      post('/learning_partners', params:)
      expect(response).to have_http_status(:bad_request)
    end

    it 'Requires banner size to be less than 1 MB' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: partner.about,
          banner: big_image_file
        }
      }
      post('/learning_partners', params:)
      expect(response).to have_http_status(:bad_request)
    end

    it 'Requires content type to be jpg/png or jpeg' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: partner.about,
          banner: pdf_file
        }
      }
      post('/learning_partners', params:)
      expect(response).to have_http_status(:bad_request)
    end

    it 'Creates a new partner' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: partner.about,
          logo: image_file,
          banner: image_file,
          supported_countries: partner.supported_countries
        }
      }

      post('/learning_partners', params:)
      expect(response).to redirect_to(new_learning_partner_payment_plan_path(LearningPartner.first))
      expect(assigns(:learning_partner).logo).not_to be_nil
      expect(assigns(:learning_partner).banner).not_to be_nil
      expect(flash[:notice]).to eq(I18n.t('resource.created', resource_name: 'Learning Partner'))
    end

    it 'Creates a default team for a partner' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: partner.about,
          logo: image_file,
          banner: image_file,
          supported_countries: partner.supported_countries
        }
      }

      expect do
        post('/learning_partners', params:)
      end.to change(Team, :count).by(1)

      expect(Team.last.learning_partner).to eq(assigns(:learning_partner))
    end

    it 'Publishes an event onboarding_initiated' do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          content: partner.about,
          supported_countries: partner.supported_countries
        }
      }

      expect do
        post '/learning_partners', params:
      end.to change(Event, :count).by(1)

      event = Event.last
      expect(event.name).to eq('onboarding_initiated')
      expect(event.partner_id).to eq(assigns[:learning_partner].id)
    end
  end
end
