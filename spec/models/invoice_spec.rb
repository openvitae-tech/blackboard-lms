# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }

  before do
    @manager = create(:user, :manager, team:, learning_partner:)
    @learner = create(:user, :learner, team:, learning_partner:)
    @invoice = create(:invoice, learning_partner:)
  end

  describe '#billable_days' do
    it 'is not valid without billable_days' do
      @invoice.billable_days = ''
      expect(@invoice).not_to be_valid
      expect(@invoice.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                     field: 'Billable days'))
    end
  end

  describe '#amount' do
    it 'is not valid without amount' do
      @invoice.amount = ''
      expect(@invoice).not_to be_valid
      expect(@invoice.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                     field: 'Amount'))
    end
  end

  describe '#bill_date' do
    it 'is not valid without bill_date' do
      @invoice.bill_date = ''
      expect(@invoice).not_to be_valid
      expect(@invoice.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                     field: 'Bill date'))
    end
  end

  describe '#status' do
    it 'is not valid without status' do
      @invoice.status = ''
      expect(@invoice).not_to be_valid
      expect(@invoice.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                     field: 'Status'))
    end
  end

  describe '#active_users' do
    it 'is not valid without active_users' do
      @invoice.active_users = ''
      expect(@invoice).not_to be_valid
      expect(@invoice.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                     field: 'Active users'))
    end
  end

  describe '#learning_partner' do
    it 'is not valid without learning partner' do
      @invoice.learning_partner = nil
      expect(@invoice).not_to be_valid
      expect(@invoice.errors.full_messages.to_sentence).to include(t('must_exist',
                                                                     entity: 'Learning partner'))
    end
  end
end
