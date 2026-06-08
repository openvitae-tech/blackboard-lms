# frozen_string_literal: true

require_relative '../rails_helper'

RSpec.describe UiHelper, type: :helper do
  def render_card(**kwargs)
    defaults = {
      title: 'Introduction to Ruby on Rails',
      banner_url: nil,
      modules_count: 8,
      duration: '2h 30m',
      enroll_count: 120,
      categories: []
    }
    html = helper.course_card_component(**defaults, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#course_card_component' do
    it 'renders the outer card wrapper' do
      doc = render_card
      expect(doc.at_css('div.rounded-xl')).to be_present
    end

    it 'renders the title' do
      doc = render_card(title: 'Advanced Rails')
      expect(doc.text).to include('Advanced Rails')
    end

    describe 'banner' do
      it 'renders an img tag when banner_url is present' do
        doc = render_card(banner_url: '/images/banner.jpg')
        expect(doc.at_css('img')['src']).to include('banner.jpg')
      end

      it 'renders a placeholder div when banner_url is blank' do
        doc = render_card(banner_url: nil)
        expect(doc.at_css('img')).to be_nil
        expect(doc.at_css('div.bg-primary-light-50')).to be_present
      end
    end

    describe 'duration' do
      it 'renders the duration badge when present' do
        doc = render_card(duration: '3h 15m')
        expect(doc.text).to include('3h 15m')
      end

      it 'omits the duration badge when nil' do
        doc = render_card(duration: nil)
        expect(doc.at_css('div.bg-primary-light-100')).to be_nil
      end
    end

    describe 'modules_count and modules_label' do
      it 'defaults to Lesson label' do
        doc = render_card(modules_count: 5)
        expect(doc.text).to include('5 Lessons')
      end

      it 'singularises the label for a count of 1' do
        doc = render_card(modules_count: 1)
        expect(doc.text).to include('1 Lesson')
      end

      it 'uses a custom modules_label when provided' do
        doc = render_card(modules_count: 4, modules_label: 'Document')
        expect(doc.text).to include('4 Documents')
      end

      it 'singularises a custom label for a count of 1' do
        doc = render_card(modules_count: 1, modules_label: 'Document')
        expect(doc.text).to include('1 Document')
      end
    end

    describe 'enroll_count' do
      it 'renders the enrolment count when present' do
        doc = render_card(enroll_count: 99)
        expect(doc.text).to include('99')
      end

      it 'renders the divider when enroll_count is present' do
        doc = render_card(enroll_count: 10)
        expect(doc.at_css('div.w-\[1px\]')).to be_present
      end

      it 'omits the enrolment count when nil' do
        doc = render_card(enroll_count: nil)
        # icon() renders <svg class="..."> with no data-src; with rating:nil (default)
        # only the lessons icon is present, so exactly one SVG should be rendered.
        expect(doc.css('svg').count).to eq(1)
      end

      it 'omits the divider when enroll_count is nil' do
        doc = render_card(enroll_count: nil)
        expect(doc.at_css('div.w-\[1px\]')).to be_nil
      end
    end

    describe 'classroom kit variant (no duration, no enroll_count, Document label)' do
      def render_kit(**kwargs)
        render_card(
          duration: nil,
          enroll_count: nil,
          modules_label: 'Document',
          **kwargs
        )
      end

      it 'renders the document count label' do
        doc = render_kit(modules_count: 3)
        expect(doc.text).to include('3 Documents')
      end

      it 'hides the duration badge' do
        doc = render_kit
        expect(doc.at_css('div.bg-primary-light-100')).to be_nil
      end

      it 'hides the enrolment row and divider' do
        doc = render_kit
        expect(doc.at_css('div.w-\[1px\]')).to be_nil
      end
    end

    describe 'rating' do
      it 'renders the rating when present' do
        doc = render_card(rating: '4.8')
        expect(doc.text).to include('4.8')
      end

      it 'omits the rating block when nil' do
        doc = render_card(rating: nil)
        expect(doc.css('[class*="star"]')).to be_empty
      end

      it 'renders the rating on the right side of the stats row' do
        doc = render_card(rating: '4.5', modules_count: 3)
        stats_row = doc.at_css('div.flex.items-center.justify-between')
        expect(stats_row).to be_present
        element_children = stats_row.children.select(&:element?)
        expect(element_children.last.text).to include('4.5')
      end
    end

    describe 'type_tag' do
      it 'renders the type tag label when present' do
        doc = render_card(type_tag: { label: 'Course', bg_color: 'bg-primary-light-200', text_color: 'text-white' })
        expect(doc.text).to include('Course')
      end

      it 'applies the supplied bg_color class to the type tag' do
        doc = render_card(type_tag: { label: 'Classroom Kit', bg_color: 'bg-secondary-light-200',
                                      text_color: 'text-white' })
        expect(doc.at_css('div.bg-secondary-light-200')).to be_present
      end

      it 'omits the type tag when nil' do
        doc = render_card(type_tag: nil)
        expect(doc.css('div.rounded-bl-xl.rounded-br-xl').select { |n| n.text.strip.present? }).to be_empty
      end

      it 'uses pb-4 on the content section when type_tag is present' do
        doc = render_card(type_tag: { label: 'Course', bg_color: 'bg-primary-light-200', text_color: 'text-white' })
        content = doc.at_css('div.pb-4')
        expect(content).to be_present
      end

      it 'uses pb-5 on the content section when type_tag is absent' do
        doc = render_card(type_tag: nil)
        content = doc.at_css('div.pb-5')
        expect(content).to be_present
      end
    end

    describe 'progress bar' do
      it 'renders a progress bar at the correct width' do
        doc = render_card(progress: 75)
        bar = doc.css('[style*="width"]').find { |el| el['style'].include?('75%') }
        expect(bar).to be_present
      end

      it 'omits the progress bar when nil' do
        doc = render_card(progress: nil)
        expect(doc.css('[style*="width"]')).to be_empty
      end
    end

    describe 'badge' do
      it 'renders the badge label' do
        doc = render_card(badge: { label: 'Beginner' })
        expect(doc.text).to include('Beginner')
      end

      it 'applies default bg and text colour when only label is given' do
        doc = render_card(badge: { label: 'New' })
        expect(doc.at_css('div.bg-secondary')).to be_present
      end

      it 'uses caller-supplied bg_color and text_color' do
        doc = render_card(badge: { label: 'Hot', bg_color: 'bg-danger-light', text_color: 'text-danger-dark' })
        expect(doc.at_css('div.bg-danger-light')).to be_present
      end

      it 'omits the badge when nil' do
        doc = render_card(badge: nil)
        expect(doc.at_css('div.bg-secondary')).to be_nil
      end
    end

    describe 'categories' do
      it 'renders up to 2 categories' do
        doc = render_card(categories: %w[Ruby Rails Go])
        expect(doc.text).to include('Ruby')
        expect(doc.text).to include('Rails')
      end

      it 'shows an overflow count when there are more than 2 categories' do
        doc = render_card(categories: %w[Ruby Rails Go Python])
        expect(doc.text).to include('+2')
      end

      it 'shows no overflow for 2 or fewer categories' do
        doc = render_card(categories: %w[Ruby Rails])
        expect(doc.text).not_to match(/\+\d/)
      end
    end
  end
end
