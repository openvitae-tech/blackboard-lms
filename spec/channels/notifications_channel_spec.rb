# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsChannel, type: :channel do
  let(:user) { create(:user, :learner) }

  before do
    stub_connection current_user: user
  end

  it 'successfully subscribes and streams for the current_user' do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(user)
  end

  it 'receives broadcasted message for the current_user' do
    message = { body: 'You have a new message.' }

    expect do
      described_class.broadcast_to(user, message)
    end.to have_broadcasted_to(user).with(message)
  end
end
