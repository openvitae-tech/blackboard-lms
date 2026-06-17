# frozen_string_literal: true

require_relative '../rails_helper'

RSpec.describe UiHelper, type: :helper do
  def render_card(**kwargs)
    defaults = {
      title: 'Test Course',
      banner_url: nil,
      duration: '2h 30m',
      modules_count: '5 modules',
      enroll_count: '120 enrolled',
      categories: []
    }
    html = helper.long_course_card_component(**defaults, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#long_course_card_component' do
    it 'renders the outer card wrapper' do
      doc = render_card
      expect(doc.at_css('div.rounded-lg')).to be_present
    end

    it 'renders the title' do
      doc = render_card(title: 'Ruby on Rails')
      expect(doc.text).to include('Ruby on Rails')
    end

    it 'renders the duration' do
      doc = render_card(duration: '3h 15m')
      expect(doc.text).to include('3h 15m')
    end

    it 'renders modules_count' do
      doc = render_card(modules_count: '8 modules')
      expect(doc.text).to include('8 modules')
    end

    it 'renders enroll_count' do
      doc = render_card(enroll_count: '200 enrolled')
      expect(doc.text).to include('200 enrolled')
    end

    describe 'banner' do
      it 'renders an img tag when banner_url is present' do
        doc = render_card(banner_url: '/images/banner.jpg')
        expect(doc.at_css('img')).to be_present
        expect(doc.at_css('img')['src']).to include('banner.jpg')
      end

      it 'renders a placeholder div when banner_url is blank' do
        doc = render_card(banner_url: nil)
        expect(doc.at_css('img')).to be_nil
        expect(doc.at_css('div.bg-primary-light-50')).to be_present
      end
    end

    describe 'checkbox' do
      it 'renders no checkbox when checkbox is false' do
        doc = render_card(checkbox: false)
        expect(doc.at_css('input[type="checkbox"]')).to be_nil
      end

      it 'raises ArgumentError when checkbox is truthy but not a Hash' do
        expect { render_card(checkbox: true) }.to raise_error(ArgumentError, /Hash/)
      end

      it 'renders a checkbox when checkbox is a Hash' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '42' })
        expect(doc.at_css('input[type="checkbox"]')).to be_present
      end

      it 'merges a caller-supplied class with the base class instead of raising' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '1', class: 'extra-class' })
        input = doc.at_css('input[type="checkbox"]')
        expect(input['class']).to include('extra-class')
        expect(input['class']).to include('cursor-pointer')
      end

      it 'uses the caller-supplied name' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '7' })
        expect(doc.at_css('input[type="checkbox"]')['name']).to eq('course_ids[]')
      end

      it 'uses the caller-supplied value' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '7' })
        expect(doc.at_css('input[type="checkbox"]')['value']).to eq('7')
      end

      it 'uses the caller-supplied id' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '7', id: 'course_7' })
        expect(doc.at_css('input[type="checkbox"]')['id']).to eq('course_7')
      end

      it 'sets id to nil when no :id is given, preventing Rails from deriving a duplicate id' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '1' })
        expect(doc.at_css('input[type="checkbox"]')['id']).to be_nil
      end

      it 'renders an unchecked checkbox by default' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '1' })
        expect(doc.at_css('input[type="checkbox"]')['checked']).to be_nil
      end

      it 'renders a pre-checked checkbox when checked: true is passed' do
        doc = render_card(checkbox: { name: 'course_ids[]', value: '1', checked: true })
        expect(doc.at_css('input[type="checkbox"]')['checked']).to eq('checked')
      end

      it 'does not produce duplicate ids across multiple cards without explicit id' do
        html1 = helper.long_course_card_component(
          title: 'A', banner_url: nil, duration: '1h', modules_count: '1', enroll_count: '1',
          categories: [], checkbox: { name: 'course_ids[]', value: '1' }
        )
        html2 = helper.long_course_card_component(
          title: 'B', banner_url: nil, duration: '2h', modules_count: '2', enroll_count: '2',
          categories: [], checkbox: { name: 'course_ids[]', value: '2' }
        )
        combined = Nokogiri::HTML::DocumentFragment.parse(html1 + html2)
        ids = combined.css('input[type="checkbox"]').map { |el| el['id'] }.compact
        expect(ids.uniq.length).to eq(ids.length)
      end
    end

    describe 'description tooltip' do
      it 'renders the tooltip when description is present' do
        doc = render_card(description: 'Learn Rails fast')
        expect(doc.text).to include('Learn Rails fast')
      end

      it 'omits the tooltip when description is blank' do
        doc = render_card(description: nil)
        expect(doc.css('p.general-text-md-normal').map(&:text)).not_to include('Learn Rails fast')
      end
    end

    describe 'highlights' do
      it 'renders each highlight inside the tooltip' do
        doc = render_card(description: 'A course', highlights: %w[Beginner-friendly Hands-on])
        list_items = doc.css('li').map(&:text)
        expect(list_items).to include('Beginner-friendly', 'Hands-on')
      end

      it 'renders no list when highlights are empty' do
        doc = render_card(description: 'A course', highlights: [])
        expect(doc.at_css('ul')).to be_nil
      end
    end

    describe 'badge' do
      it 'renders badge label when badge is present' do
        doc = render_card(badge: { label: 'New', bg_color: 'bg-green-100', text_color: 'text-green-800' })
        expect(doc.text).to include('New')
      end

      it 'applies default bg and text colour classes when only label is provided' do
        doc = render_card(badge: { label: 'Hot' })
        badge_el = doc.at_css('div.bg-secondary')
        expect(badge_el).to be_present
        expect(badge_el['class']).to include('text-primary-dark')
      end

      it 'uses caller-supplied bg_color and text_color over defaults' do
        doc = render_card(badge: { label: 'Sale', bg_color: 'bg-red-100', text_color: 'text-red-800' })
        badge_el = doc.at_css('div.bg-red-100')
        expect(badge_el).to be_present
        expect(badge_el['class']).to include('text-red-800')
      end

      it 'omits the badge entirely when badge is nil' do
        doc = render_card(badge: nil)
        expect(doc.at_css('div.bg-secondary')).to be_nil
      end
    end

    describe 'rating' do
      it 'renders the rating value when present' do
        doc = render_card(rating: '4.5')
        expect(doc.text).to include('4.5')
      end

      it 'omits the rating block when rating is nil' do
        doc = render_card(rating: nil)
        expect(doc.css('[class*="star"]')).to be_empty
      end

      it 'renders the rating after modules and enroll in the stats row' do
        doc = render_card(rating: '4.2', modules_count: '6 modules', enroll_count: '50 enrolled')
        stats_row = doc.at_css('div.flex.gap-1.md\\:gap-1.items-center')
        expect(stats_row).to be_present
        element_children = stats_row.children.select(&:element?)
        expect(element_children.last.text).to include('4.2')
      end
    end

    describe 'type_tag' do
      it 'renders the type tag label when present' do
        tag = { label: 'Course', bg_color: 'bg-primary-light-200', text_color: 'text-grey-dark' }
        doc = render_card(type_tag: tag)
        expect(doc.text).to include('Course')
      end

      it 'applies the supplied bg_color class to the type tag' do
        tag = { label: 'Classroom Kit', bg_color: 'bg-secondary-light-200', text_color: 'text-grey-dark' }
        doc = render_card(type_tag: tag)
        expect(doc.at_css('div.bg-secondary-light-200')).to be_present
      end

      it 'omits the type tag when nil' do
        doc = render_card(type_tag: nil)
        expect(doc.css('div.bg-primary-light-200, div.bg-secondary-light-200, div.bg-gold-dark')).to be_empty
      end
    end

    describe 'progress bar' do
      it 'renders a progress bar with the correct width when progress is present' do
        doc = render_card(progress: 60)
        bar = doc.css('[style*="width"]').find { |el| el['style'].include?('60%') }
        expect(bar).to be_present
      end

      it 'omits the progress bar when progress is nil' do
        doc = render_card(progress: nil)
        expect(doc.css('[style*="width"]')).to be_empty
      end
    end

    describe 'categories' do
      it 'renders up to 2 categories as chips' do
        doc = render_card(categories: %w[Ruby Rails Go])
        doc.css('[class*="chip"], span[class*="rounded"]').select do |el|
          %w[Ruby Rails].any? do |c|
            el.text.include?(c)
          end
        end
        expect(doc.text).to include('Ruby')
        expect(doc.text).to include('Rails')
      end

      it 'shows an overflow count when there are more than 2 categories' do
        doc = render_card(categories: %w[Ruby Rails Go Python])
        expect(doc.text).to include('+2')
      end

      it 'shows no overflow when there are 2 or fewer categories' do
        doc = render_card(categories: %w[Ruby Rails])
        expect(doc.text).not_to match(/\+\d/)
      end

      it 'renders nothing for categories when the list is empty' do
        doc = render_card(categories: [])
        expect(doc.css('[data-chip]')).to be_empty
      end
    end
  end
end
