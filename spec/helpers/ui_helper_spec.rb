# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UiHelper, type: :helper do
  describe 'icon' do
    it 'throws error if the icon does not exists' do
      expect { helper.icon('foo') }.to raise_error(Errno::ENOENT)
    end

    it 'renders svg icon within a span element' do
      html = helper.icon('bell')
      html = Nokogiri::HTML::DocumentFragment.parse(html)
      # <span><svg> ...</svg></span>
      expect(html.children.count).to eq(1)
      expect(html.children.first.name).to eq('span')
      expect(html.children.first.children.count).to eq(1)
      expect(html.children.first.children.first.name).to eq('svg')
    end

    it 'accepts css classess and set the class on the svg element' do
      html = helper.icon('bell', css: 'myclass1 myclass2')
      html = Nokogiri::HTML::DocumentFragment.parse(html)
      svg = html.children.first.children.first
      expect(svg.attr('class')).to include('myclass1 myclass2')
    end

    it 'accepts span_css attribute and set the class on the outer span element' do
      html = helper.icon('bell', span_css: 'myclass1 myclass2')
      html = Nokogiri::HTML::DocumentFragment.parse(html)
      span = html.children.first
      expect(span.attr('class')).to include('myclass1 myclass2')
    end
  end
end
