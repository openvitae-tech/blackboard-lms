# frozen_string_literal: true

RSpec.describe 'Request spec for PaymentPlans' do
  let(:user) { create(:user, :admin) }
  let(:learning_partner) { create :learning_partner }
  let(:learner) { create(:user, :learner, learning_partner:) }

  before do
    sign_in user
  end

  describe 'GET /payment_plan/new' do
    it 'Renders the new template for admin' do
      get new_learning_partner_payment_plan_path(learning_partner)
      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'Returns unauthorized for non-admin' do
      sign_in learner
      get new_learning_partner_payment_plan_path(learning_partner)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'Returns unauthorized if payment plan is already created' do
      create(:payment_plan, learning_partner:)
      get new_learning_partner_payment_plan_path(learning_partner)

      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'POST /payment_plans' do
    it 'Allow creating payment plan by admin' do
      expect do
        post learning_partner_payment_plan_path(learning_partner), params: payment_plan_params
      end.to change(PaymentPlan, :count).by(1)
      total_seats = learning_partner.payment_plan.total_seats
      expect(total_seats).to eq(payment_plan_params.dig(:payment_plan, :total_seats))
      expect(Event.last.name).to eq('payment_plan_modified')
      expect(flash[:notice]).to eq(I18n.t('resource.created', resource_name: 'Payment plan'))
    end

    it 'Returns unauthorized for non-admin' do
      sign_in learner

      post learning_partner_payment_plan_path(learning_partner), params: payment_plan_params

      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'Returns unauthorized if payment plan is already created' do
      create(:payment_plan, learning_partner:)
      post learning_partner_payment_plan_path(learning_partner), params: payment_plan_params

      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'Create payment plan failure' do
      post learning_partner_payment_plan_path(learning_partner), params: { payment_plan: { start_date: nil } }

      expect(response.status).to eq(422)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET /payment_plan/edit' do
    before do
      create :payment_plan, learning_partner:
    end

    it 'Renders the edit template for admin' do
      get edit_learning_partner_payment_plan_path(learning_partner)

      expect(response.status).to be(200)
      expect(response).to render_template(:edit)
    end

    it 'Returns unauthorized for non-admin' do
      sign_in learner

      get edit_learning_partner_payment_plan_path(learning_partner)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'PUT /payment_plans' do
    before do
      @payment_plan = create :payment_plan, learning_partner:
    end

    it 'Allow updating payment plan by admin' do
      put learning_partner_payment_plan_path(learning_partner), params: payment_plan_params

      @payment_plan.reload
      expect(@payment_plan.total_seats).to eq(payment_plan_params[:payment_plan][:total_seats])
      expect(@payment_plan.per_seat_cost).to eq(payment_plan_params[:payment_plan][:per_seat_cost])
      expect(Event.last.name).to eq('payment_plan_modified')
      expect(flash[:success]).to eq(I18n.t('resource.updated', resource_name: 'Payment plan'))
    end

    it 'Returns unauthorized for non-admin' do
      sign_in learner

      put learning_partner_payment_plan_path(learning_partner), params: payment_plan_params
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end

    it 'Update payment plan failure' do
      put learning_partner_payment_plan_path(learning_partner), params: { payment_plan: { start_date: nil } }

      expect(response.status).to eq(422)
      expect(response).to render_template(:edit)
    end
  end

  private

  def payment_plan_params
    {
      payment_plan: {
        start_date: Time.zone.now,
        end_date: 1.month.from_now,
        total_seats: 30,
        per_seat_cost: 500
      }
    }
  end
end
