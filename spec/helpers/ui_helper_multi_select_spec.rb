# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UiHelper, type: :helper do
  let(:options) { [%w[Ruby ruby], %w[Python python], %w[Go go]] }

  def render_component(**kwargs)
    html = helper.multi_select_component(name: :languages, options:, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#multi_select_component' do
    it 'renders the stimulus controller wrapper' do
      doc = render_component
      expect(doc.at_css('[data-controller="multi-select"]')).to be_present
    end

    describe 'label' do
      it 'renders a label element when label is provided' do
        doc = render_component(label: 'Languages')
        expect(doc.at_css('label span').text.strip).to eq('Languages')
      end

      it 'omits the label element when label is not provided' do
        doc = render_component
        expect(doc.at_css('label')).to be_nil
      end
    end

    describe 'support text' do
      it 'renders support text when provided' do
        doc = render_component(support_text: 'Pick at least one')
        expect(doc.text).to include('Pick at least one')
      end

      it 'renders the error message as support text when error is provided' do
        doc = render_component(error: 'Required')
        expect(doc.text).to include('Required')
      end
    end

    describe 'placeholder' do
      it 'is visible when no values are selected' do
        doc = render_component(placeholder: 'Select languages')
        placeholder = doc.at_css('[data-multi-select-target="placeholder"]')
        expect(placeholder).to be_present
        expect(placeholder.text.strip).to eq('Select languages')
        expect(placeholder['class']).not_to include('hidden')
      end

      it 'is hidden when values are pre-selected' do
        doc = render_component(placeholder: 'Select languages', value: ['ruby'])
        placeholder = doc.at_css('[data-multi-select-target="placeholder"]')
        expect(placeholder['class']).to include('hidden')
      end

      it 'is absent when no placeholder is provided' do
        doc = render_component
        expect(doc.at_css('[data-multi-select-target="placeholder"]')).to be_nil
      end
    end

    describe 'chips and options' do
      it 'renders one chip wrapper per option' do
        doc = render_component
        expect(doc.css('[data-multi-select-target="chip"]').count).to eq(options.count)
      end

      it 'renders one option row per option' do
        doc = render_component
        expect(doc.css('[data-multi-select-target="option"]').count).to eq(options.count)
      end
    end

    context 'with pre-selected values' do
      let(:doc) { render_component(value: ['ruby']) }

      it 'shows the chip for the selected value' do
        chip = doc.css('[data-multi-select-target="chip"]').find { |el| el['data-value'] == 'ruby' }
        expect(chip['class']).not_to include('hidden')
      end

      it 'hides chips for unselected values' do
        chip = doc.css('[data-multi-select-target="chip"]').find { |el| el['data-value'] == 'python' }
        expect(chip['class']).to include('hidden')
      end

      it 'hides the selected value from the options dropdown' do
        option = doc.css('[data-multi-select-target="option"]').find { |el| el['data-value'] == 'ruby' }
        expect(option['class']).to include('hidden')
      end

      it 'shows unselected values in the options dropdown' do
        option = doc.css('[data-multi-select-target="option"]').find { |el| el['data-value'] == 'python' }
        expect(option['class']).not_to include('hidden')
      end

      it 'enables the hidden input for the selected value' do
        input = doc.css('[data-multi-select-target="hiddenInput"]').find { |el| el['data-value'] == 'ruby' }
        expect(input['disabled']).to be_nil
      end

      it 'disables hidden inputs for unselected values' do
        input = doc.css('[data-multi-select-target="hiddenInput"]').find { |el| el['data-value'] == 'python' }
        expect(input['disabled']).to be_present
      end
    end

    describe 'html_options' do
      it 'applies the base wrapper class by default' do
        doc = render_component
        wrapper = doc.at_css('[data-controller="multi-select"]')
        expect(wrapper['class']).to eq('w-full flex flex-col gap-1')
      end

      it 'merges a caller-supplied class with the base wrapper class' do
        doc = render_component(html_options: { class: 'extra-class' })
        wrapper = doc.at_css('[data-controller="multi-select"]')
        expect(wrapper['class']).to include('w-full flex flex-col gap-1')
        expect(wrapper['class']).to include('extra-class')
      end

      it 'applies extra attributes to the wrapper div' do
        doc = render_component(html_options: { id: 'my-select', data: { foo: 'bar' } })
        wrapper = doc.at_css('[data-controller="multi-select"]')
        expect(wrapper['id']).to eq('my-select')
        expect(wrapper['data-foo']).to eq('bar')
      end
    end

    context 'when disabled' do
      it 'sets the disabled value on the stimulus controller' do
        doc = render_component(disabled: true)
        wrapper = doc.at_css('[data-controller="multi-select"]')
        expect(wrapper['data-multi-select-disabled-value']).to eq('true')
      end
    end

    context 'with a form object' do
      it 'uses the Rails array param convention for hidden input names' do
        form = instance_double(ActionView::Helpers::FormBuilder, object_name: 'course', object: nil)
        html = helper.multi_select_component(form:, name: :language_ids, options:)
        doc = Nokogiri::HTML::DocumentFragment.parse(html)
        input = doc.css('[data-multi-select-target="hiddenInput"]').first
        expect(input['name']).to eq('course[language_ids][]')
      end
    end
  end
end
