# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exports::SpreadsheetHelpers do
  subject(:helper) { Class.new { include Exports::SpreadsheetHelpers }.new }

  describe '#duration_label' do
    it 'formats a date range as "DD Mon YYYY – DD Mon YYYY"' do
      range = Date.new(2024, 1, 1).beginning_of_day..Date.new(2024, 1, 31).end_of_day
      expect(helper.duration_label(range)).to eq('01 Jan 2024 – 31 Jan 2024')
    end
  end

  describe '#delta_label' do
    it 'returns "No change" for zero' do
      expect(helper.delta_label(0)).to eq('No change')
    end

    it 'returns "No change" for nil' do
      expect(helper.delta_label(nil)).to eq('No change')
    end

    it 'prefixes positive values with +' do
      expect(helper.delta_label(5)).to eq('+5')
    end

    it 'returns a plain string for negative values' do
      expect(helper.delta_label(-3)).to eq('-3')
    end
  end

  describe '#format_seconds' do
    it 'returns "0m" for zero' do
      expect(helper.format_seconds(0)).to eq('0m')
    end

    it 'returns "0m" for nil' do
      expect(helper.format_seconds(nil)).to eq('0m')
    end

    it 'formats seconds under one hour as minutes only' do
      expect(helper.format_seconds(1800)).to eq('30m')
    end

    it 'formats seconds over one hour as hours and minutes' do
      expect(helper.format_seconds(5400)).to eq('1h 30m')
    end

    it 'omits minutes when there are none' do
      expect(helper.format_seconds(7200)).to eq('2h 0m')
    end
  end
end
