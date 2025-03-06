# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Invoices', type: :request do
  let(:learning_partner) { create :learning_partner }
  let(:admin_user) { create(:user, :admin) }
  let(:owner) { create(:user, :owner, learning_partner:) }
  let(:learner) { create(:user, :learner, learning_partner:) }

  before do
    travel_to Time.zone.now.last_month do
      @invoice_one = create(:invoice, learning_partner:)
    end
    @invoice_two = create(:invoice, learning_partner:)
  end

  describe 'GET /invoices' do
    it 'Allow listing learning partner invoices by admin' do
      sign_in admin_user

      get invoices_path(id: learning_partner.id)
      learning_partner_invoices = learning_partner.invoices.pluck(:id).sort
      expect(response.status).to be(200)
      expect(assigns(:invoices).pluck(:id).sort).to eq(learning_partner_invoices)
    end

    it 'Allow listing invoices to the owner' do
      sign_in owner

      get invoices_path

      learning_partner_invoices = learning_partner.invoices.pluck(:id).sort
      expect(response.status).to be(200)
      expect(assigns(:invoices).pluck(:id).sort).to eq(learning_partner_invoices)
    end

    it 'Unauthorized when invoices is accessed by non-admin or non-owner' do
      sign_in learner

      get invoices_path

      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to('/error_401')
    end
  end
end
