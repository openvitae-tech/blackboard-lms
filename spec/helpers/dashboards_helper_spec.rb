# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardsHelper, type: :helper do
  describe '#safe_origin_path' do
    it 'allows a plain relative path' do
      expect(helper.safe_origin_path('/dashboards')).to eq('/dashboards')
    end

    it 'allows a relative path with query string' do
      expect(helper.safe_origin_path('/dashboards?team_id=1')).to eq('/dashboards?team_id=1')
    end

    it 'blocks protocol-relative URLs (double slash)' do
      expect(helper.safe_origin_path('//evil.com')).to be_nil
    end

    it 'blocks absolute URLs with https scheme' do
      expect(helper.safe_origin_path('https://evil.com/phish')).to be_nil
    end

    it 'blocks javascript: URIs' do
      expect(helper.safe_origin_path('javascript:alert(1)')).to be_nil
    end

    it 'blocks paths containing a colon' do
      expect(helper.safe_origin_path('/foo:bar')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(helper.safe_origin_path('')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(helper.safe_origin_path(nil)).to be_nil
    end
  end
end
