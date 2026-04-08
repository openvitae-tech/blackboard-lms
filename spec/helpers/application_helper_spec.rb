# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#query_url' do
    it 'merges a path with query params' do
      path = '/users?id=1'
      query = { page: 2 }
      expect(helper.query_url(path, query)).to eq('/users?id=1&page=2')
    end

    it 'removes nil parameters in query' do
      path = '/users?id=1'
      query = { page: nil }
      expect(helper.query_url(path, query)).to eq('/users?id=1')
    end

    it 'Keeps the blank parameters in path' do
      path = '/users?id='
      query = { page: 1 }
      expect(helper.query_url(path, query)).to eq('/users?id=&page=1')
    end

    it 'When the path parameters in path is empty' do
      path = ''
      query = { page: 1 }
      expect(helper.query_url(path, query)).to eq('')
    end

    it 'When the path parameters in path is nil' do
      path = nil
      query = { page: 1 }
      expect(helper.query_url(path, query)).to eq('')
    end
  end

  describe '#sidebar_active' do
    it 'returns item-selected when page matches active_nav' do
      expect(helper.sidebar_active('courses', 'courses')).to eq('item-selected')
    end

    it 'returns item-selected when page matches controller_name and active_nav is nil' do
      allow(helper).to receive(:controller_name).and_return('courses')
      expect(helper.sidebar_active('courses', nil)).to eq('item-selected')
    end

    it 'returns nil when page does not match active_nav' do
      expect(helper.sidebar_active('programs', 'courses')).to be_nil
    end

    it 'returns nil when both active_nav and controller_name do not match' do
      allow(helper).to receive(:controller_name).and_return('lessons')
      expect(helper.sidebar_active('programs', nil)).to be_nil
    end
  end
end
