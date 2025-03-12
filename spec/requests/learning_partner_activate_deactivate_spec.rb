# frozen_string_literal: true

RSpec.describe 'Request spec for LearningPartner state changes' do
  describe 'PUT /learning_partners/:id/(activate|deactivate)' do
    before do
      @admin_user = create :user, :admin
      sign_in @admin_user
    end

    it 'Sets the default status as active' do
      user = create :user, :owner
      expect(user.learning_partner).to be_active
      expect(user).to be_active_for_authentication
    end

    it 'unauthorised if the partner is already active' do
      user = create :user, :owner
      put "/learning_partners/#{user.learning_partner.id}/activate"
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'unauthorised if the partner is already deactivated' do
      user = create :user, :owner
      user.learning_partner.deactivate
      put "/learning_partners/#{user.learning_partner.id}/deactivate"
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Deactivate/block the learning partner' do
      user = create :user, :owner
      put "/learning_partners/#{user.learning_partner.id}/deactivate"
      expect(response).to redirect_to(user.learning_partner)
    end

    it 'Deactivating the learning partner should destroy impersonation' do
      learning_partner = create :learning_partner
      support_user = create(:user, role: 'support', learning_partner:)

      REDIS_CLIENT.call('SET', "impersonated_support_user_#{support_user.id}",
                        { impersonator_id: @admin_user.id, impersonating: true }.to_json)

      put deactivate_learning_partner_path(learning_partner)
      expect(REDIS_CLIENT.call('GET', "impersonated_support_user_#{support_user.id}")).to be_nil
    end

    it "Users will be logged out and they won't be able to login again" do
      user = create :user, :owner
      put "/learning_partners/#{user.learning_partner.id}/deactivate"
      expect(user.reload).not_to be_active_for_authentication
    end

    it 'Admin can reactivate a partner again' do
      user = create :user, :owner
      user.learning_partner.deactivate
      put "/learning_partners/#{user.learning_partner.id}/activate"
      expect(user.reload).to be_active_for_authentication
    end
  end
end
