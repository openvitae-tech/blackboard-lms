# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UiHelper, type: :helper do
  let(:steps) do
    [
      { icon_name: 'document-text', label: 'Upload doc' },
      { icon_name: 'camera',        label: 'Configure Video' },
      { icon_name: 'numbered-list', label: 'Course Structure' }
    ]
  end

  def render_component(**kwargs)
    html = helper.wizard_steps_component(steps:, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#wizard_steps_component' do
    it 'renders a step item for each step' do
      doc = render_component(current_step: 0)
      expect(doc.css('[role="listitem"]').count).to eq(steps.count)
    end

    it 'renders all step labels' do
      doc = render_component(current_step: 0)
      labels = doc.css('[role="listitem"] span.whitespace-nowrap').map(&:text).map(&:strip)
      expect(labels).to eq(['Upload doc', 'Configure Video', 'Course Structure'])
    end

    context 'when current_step is 0' do
      let(:doc) { render_component(current_step: 0) }

      it 'applies active background and border to the first step circle' do
        first_circle = doc.css('[role="listitem"]').first.at_css('.rounded-full')
        expect(first_circle['class']).to include('bg-primary-light-100', 'border-2', 'border-primary', 'text-primary')
      end

      it 'applies upcoming styling to subsequent step circles' do
        second_circle = doc.css('[role="listitem"]')[1].at_css('.rounded-full')
        expect(second_circle['class']).to include('bg-white', 'text-slate-grey-50')
        expect(second_circle['class']).not_to include('border-2')
      end
    end

    context 'when current_step is 1' do
      let(:doc) { render_component(current_step: 1) }

      it 'applies completed styling to the first step (blue bg, grey border, grey icon)' do
        first_circle = doc.css('[role="listitem"]').first.at_css('.rounded-full')
        expect(first_circle['class']).to include('bg-primary-light-100', 'border-slate-grey-light', 'text-slate-grey-50')
        expect(first_circle['class']).not_to include('border-2', 'border-primary')
      end

      it 'applies active styling to the second step (blue bg, blue border, blue icon)' do
        second_circle = doc.css('[role="listitem"]')[1].at_css('.rounded-full')
        expect(second_circle['class']).to include('bg-primary-light-100', 'border-2', 'border-primary', 'text-primary')
      end

      it 'applies upcoming styling to the third step' do
        third_circle = doc.css('[role="listitem"]')[2].at_css('.rounded-full')
        expect(third_circle['class']).to include('bg-white', 'text-slate-grey-50')
        expect(third_circle['class']).not_to include('border-2')
      end
    end

    it 'renders connector lines between steps' do
      doc = render_component(current_step: 0)
      connector_count = doc.css('[aria-hidden="true"]').count
      expect(connector_count).to eq(steps.count - 1)
    end

    it 'raises ArgumentError for empty steps' do
      expect { helper.wizard_steps_component(steps: [], current_step: 0) }
        .to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when current_step is not an Integer' do
      expect { helper.wizard_steps_component(steps:, current_step: '0') }
        .to raise_error(ArgumentError)
    end
  end
end
