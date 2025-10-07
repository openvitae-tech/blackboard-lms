# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppConfigService do
  subject { described_class.instance }

  describe '#external_video_hosting?' do
    it 'returns false for test env' do
      expect(described_class.instance.external_video_hosting?).to be(false)
    end
  end
end
