# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UiHelper, type: :helper do
  def render_component(**kwargs)
    html = helper.file_selector_component(type: 'image', name: :logo, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#file_selector_component' do
    it 'mounts the stimulus controller' do
      doc = render_component
      expect(doc.at_css('[data-controller="file-selector"]')).to be_present
    end

    it 'renders the drop zone wrapper target inside the container' do
      doc = render_component
      expect(doc.at_css('[data-file-selector-target="wrapper"]')).to be_present
    end

    describe 'label' do
      it 'renders label text when label is provided' do
        doc = render_component(label: 'Company Logo')
        expect(doc.text).to include('Company Logo')
      end

      it 'omits label element when not provided' do
        doc = render_component
        expect(doc.at_css('.file-selector-component-container > span')).to be_nil
      end
    end

    describe 'support text' do
      it 'renders support_text when provided' do
        doc = render_component(support_text: 'Max 10MB')
        expect(doc.text).to include('Max 10MB')
      end

      it 'renders support_text_two when provided' do
        doc = render_component(support_text: 'Max 10MB', support_text_two: '.jpg,.png')
        expect(doc.text).to include('.jpg,.png')
      end

      it 'renders error as support text and applies danger style' do
        doc = render_component(error: 'File format not supported')
        support = doc.at_css('.file-selector-support-text')
        expect(support['class']).to include('text-danger-dark')
        expect(support.text).to include('File format not supported')
      end
    end

    describe 'file input' do
      it 'renders a hidden file input' do
        doc = render_component
        input = doc.at_css('input[type="file"]')
        expect(input).to be_present
        expect(input['class']).to include('hidden')
      end

      it 'sets the accept attribute to image types' do
        doc = render_component(type: 'image')
        expect(doc.at_css('input[type="file"]')['accept']).to eq('image/*')
      end

      it 'sets the accept attribute to document types' do
        doc = render_component(type: 'document')
        expect(doc.at_css('input[type="file"]')['accept']).to eq('.csv,.pdf,.doc,.docx')
      end

      it 'sets the accept attribute to video types' do
        doc = render_component(type: 'video')
        expect(doc.at_css('input[type="file"]')['accept']).to eq('video/*,.mp4,.mov,.avi,.mkv')
      end

      it 'does not have the multiple attribute by default' do
        doc = render_component
        expect(doc.at_css('input[type="file"]')['multiple']).to be_nil
      end

      it 'adds the multiple attribute when multiple: true' do
        doc = render_component(multiple: true)
        expect(doc.at_css('input[type="file"]')['multiple']).to be_present
      end
    end

    describe 'disabled state' do
      it 'applies the disabled pointer-events class to the wrapper' do
        doc = render_component(disabled: true)
        wrapper = doc.at_css('[data-file-selector-target="wrapper"]')
        expect(wrapper['class']).to include('pointer-events-none')
      end

      it 'sets the disabled attribute on the file input' do
        doc = render_component(disabled: true)
        expect(doc.at_css('input[type="file"]')['disabled']).to be_present
      end
    end

    describe 'error state' do
      it 'applies the danger border class to the wrapper' do
        doc = render_component(error: 'Bad file')
        wrapper = doc.at_css('[data-file-selector-target="wrapper"]')
        expect(wrapper['class']).to include('border-danger')
      end

      it 'renders the error text inside the choose file area' do
        doc = render_component(error: 'Bad file')
        expect(doc.at_css('.file-selctor-error-text').text.strip).to eq('Bad file')
      end
    end

    describe 'single file mode (default)' do
      it 'renders a selectedFileName target for single-file display' do
        doc = render_component
        expect(doc.at_css('[data-file-selector-target="selectedFileName"]')).to be_present
      end

      it 'renders a previewContainer for image type' do
        doc = render_component(type: 'image')
        expect(doc.at_css('[data-file-selector-target="previewContainer"]')).to be_present
      end

      it 'renders an img preview target for image type' do
        doc = render_component(type: 'image')
        expect(doc.at_css('[data-file-selector-target="preview"]').name).to eq('img')
      end

      it 'renders a video preview target for video type' do
        doc = render_component(type: 'video')
        expect(doc.at_css('[data-file-selector-target="preview"]').name).to eq('video')
      end

      it 'renders a document icon preview for document type' do
        doc = render_component(type: 'document')
        expect(doc.at_css('[data-file-selector-target="iconPreview"]')).to be_present
      end

      it 'does not render the file list container' do
        doc = render_component
        expect(doc.at_css('[data-file-selector-target="fileList"]')).to be_nil
      end
    end

    describe 'multiple file mode' do
      def render_multiple(**kwargs)
        render_component(multiple: true, **kwargs)
      end

      it 'renders the file list container' do
        doc = render_multiple
        expect(doc.at_css('[data-file-selector-target="fileList"]')).to be_present
      end

      it 'renders the image item template' do
        doc = render_multiple
        expect(doc.at_css('[data-file-selector-target="imageItemTemplate"]')).to be_present
      end

      it 'renders the document item template' do
        doc = render_multiple
        expect(doc.at_css('[data-file-selector-target="docItemTemplate"]')).to be_present
      end

      it 'renders the media item template' do
        doc = render_multiple
        expect(doc.at_css('[data-file-selector-target="mediaItemTemplate"]')).to be_present
      end

      it 'does not render a single-file previewContainer' do
        doc = render_multiple
        expect(doc.at_css('[data-file-selector-target="previewContainer"]')).to be_nil
      end

      it 'does not render a selectedFileName target' do
        doc = render_multiple
        expect(doc.at_css('[data-file-selector-target="selectedFileName"]')).to be_nil
      end

      it 'wraps the drop zone and list in a column gap container' do
        doc = render_multiple
        expect(doc.at_css('.flex.flex-col.gap-5')).to be_present
      end

      it 'renders photo icon inside the image item template' do
        doc = render_multiple
        template = doc.at_css('[data-file-selector-target="imageItemTemplate"]')
        expect(template.inner_html).to include('file-selector-list-icon')
      end

      it 'renders document-text icon inside the doc item template' do
        doc = render_multiple
        template = doc.at_css('[data-file-selector-target="docItemTemplate"]')
        expect(template.inner_html).to include('file-selector-list-icon')
      end

      it 'renders play-circle icon inside the media item template' do
        doc = render_multiple
        template = doc.at_css('[data-file-selector-target="mediaItemTemplate"]')
        expect(template.inner_html).to include('file-selector-list-icon')
      end
    end

    describe 'invalid type' do
      it 'raises an error for unsupported types' do
        expect do
          helper.file_selector_component(type: 'audio', name: :file)
        end.to raise_error(RuntimeError, /Invalid or missing file type/)
      end
    end

    context 'with a form object' do
      it 'uses form.file_field to render the input' do
        form = instance_double(ActionView::Helpers::FormBuilder, object_name: 'course', object: nil)
        allow(form).to receive(:file_field).and_return('<input type="file" name="course[logo]" />'.html_safe)
        html = helper.file_selector_component(form:, type: 'image', name: :logo)
        expect(html).to include('course[logo]')
      end
    end
  end
end
