# frozen_string_literal: true

require_relative '../rails_helper'

RSpec.describe UiHelper, type: :helper do
  def render_card(**kwargs)
    defaults = {
      title: 'Video',
      description: 'Upload or link a video for learners to watch.',
      icon_name: 'play-circle',
      radio_name: 'content_type',
      radio_value: 'video'
    }
    html = helper.content_type_card_component(**defaults, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#content_type_card_component' do
    it 'renders a label as the outer wrapper' do
      doc = render_card
      expect(doc.at_css('label')).to be_present
    end

    it 'renders the title' do
      doc = render_card(title: 'Quiz')
      expect(doc.text).to include('Quiz')
    end

    it 'renders the description' do
      doc = render_card(description: 'Test learner knowledge.')
      expect(doc.text).to include('Test learner knowledge.')
    end

    it 'renders a hidden radio button with the correct name and value' do
      doc = render_card(radio_name: 'content_type', radio_value: 'quiz')
      input = doc.at_css('input[type="radio"]')
      expect(input).to be_present
      expect(input['name']).to eq('content_type')
      expect(input['value']).to eq('quiz')
      expect(input['class']).to include('hidden')
    end

    it 'renders an icon element for the given icon_name' do
      doc = render_card(icon_name: 'play-circle')
      expect(doc.at_css('svg, img, [data-icon], .icon, span.icon')).to be_present
    end

    it 'renders an unchecked radio by default' do
      doc = render_card
      expect(doc.at_css('input[type="radio"]')['checked']).to be_nil
    end

    it 'renders a pre-checked radio when selected: true' do
      doc = render_card(selected: true)
      expect(doc.at_css('input[type="radio"]')['checked']).to eq('checked')
    end

    describe 'highlights' do
      it 'renders each highlight as a list item' do
        doc = render_card(highlights: ['Supports MP4', 'Auto-captioning'])
        items = doc.css('li').map(&:text).map(&:strip)
        expect(items).to include('Supports MP4', 'Auto-captioning')
      end

      it 'renders a bullet dot div for each highlight' do
        doc = render_card(highlights: ['Supports MP4', 'Auto-captioning'])
        dots = doc.css('li div.rounded-full')
        expect(dots.length).to eq(2)
      end

      it 'omits the highlights list when highlights is empty' do
        doc = render_card(highlights: [])
        expect(doc.at_css('ul')).to be_nil
      end

      it 'omits the highlights list when highlights is not provided' do
        doc = render_card
        expect(doc.at_css('ul')).to be_nil
      end
    end

    describe 'caption' do
      it 'renders the caption when present' do
        doc = render_card(caption: 'Available on Pro plan')
        expect(doc.text).to include('Available on Pro plan')
      end

      it 'omits the caption when nil' do
        doc = render_card(caption: nil)
        paragraphs = doc.css('p').map(&:text)
        expect(paragraphs).not_to include('Available on Pro plan')
      end
    end

    describe 'disabled state' do
      it 'renders a disabled radio input' do
        doc = render_card(disabled: true)
        expect(doc.at_css('input[type="radio"]')['disabled']).to be_present
      end

      it 'applies pointer-events-none to the label' do
        doc = render_card(disabled: true)
        expect(doc.at_css('label')['class']).to include('pointer-events-none')
      end

      it 'applies opacity-40 to the label (single source of dimming for all children)' do
        doc = render_card(disabled: true)
        expect(doc.at_css('label')['class']).to include('opacity-40')
      end

      it 'keeps secondary-dark colour on bullet dots (opacity-40 on the label handles disabled dimming)' do
        doc = render_card(disabled: true, highlights: %w[One Two])
        dots = doc.css('li div.rounded-full')
        dots.each { |dot| expect(dot['class']).to include('bg-secondary-dark') }
      end
    end

    describe 'enabled state' do
      it 'applies cursor-pointer to the label' do
        doc = render_card(disabled: false)
        expect(doc.at_css('label')['class']).to include('cursor-pointer')
      end

      it 'applies secondary-dark colour to the bullet dots' do
        doc = render_card(highlights: ['One'], disabled: false)
        dot = doc.at_css('li div.rounded-full')
        expect(dot['class']).to include('bg-secondary-dark')
      end
    end
  end
end
