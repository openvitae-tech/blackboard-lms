# frozen_string_literal: true

require_relative '../rails_helper'

RSpec.describe UiHelper, type: :helper do
  def render_scene(**kwargs)
    defaults = {
      scene_number: 1,
      total_scenes: 4,
      title: 'Setting up: where money sleeps',
      script: 'Lorem ipsum dolor sit amet.',
      state: :default
    }
    html = helper.scene_script_component(**defaults, **kwargs)
    Nokogiri::HTML::DocumentFragment.parse(html)
  end

  describe '#scene_script_component' do
    it 'raises ArgumentError for an invalid state' do
      expect { render_scene(state: :bogus) }.to raise_error(ArgumentError, /state must be one of/)
    end

    it 'accepts state as a string' do
      doc = render_scene(state: 'default')
      expect(doc.at_css('[data-controller="scene-script"]')).to be_present
    end

    it 'renders the scene chip' do
      doc = render_scene(scene_number: 2, total_scenes: 5)
      expect(doc.text).to include('Scene 2 of 5')
    end

    it 'renders the title' do
      doc = render_scene(title: 'The compounding effect')
      expect(doc.text).to include('The compounding effect')
    end

    it 'renders the script inside the textarea' do
      doc = render_scene(script: 'Once upon a time')
      expect(doc.at_css('textarea').text).to include('Once upon a time')
    end

    it 'wires the Stimulus controller and value attributes' do
      doc = render_scene(approve_url: '/scenes/1/approve', regenerate_url: '/scenes/1/regenerate')
      root = doc.at_css('[data-controller="scene-script"]')
      expect(root['data-scene-script-approve-url-value']).to eq('/scenes/1/approve')
      expect(root['data-scene-script-regenerate-url-value']).to eq('/scenes/1/regenerate')
    end

    describe 'default state' do
      it 'shows the Approve action' do
        doc = render_scene(state: :default)
        expect(doc.at_css('[data-scene-script-target="approveAction"]')).to be_present
      end

      it 'renders no thumbnail' do
        doc = render_scene(state: :default)
        expect(doc.at_css('[data-scene-script-target="thumbnail"]')).to be_nil
      end

      it 'leaves the textarea editable' do
        doc = render_scene(state: :default)
        textarea = doc.at_css('textarea')
        expect(textarea['disabled']).to be_nil
        expect(textarea['readonly']).to be_nil
      end

      it 'marks the disabled value as false' do
        doc = render_scene(state: :default)
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['data-scene-script-disabled-value']).to eq('false')
      end
    end

    describe 'processing state' do
      it 'renders the bundled default spinner gif when spinner_url is not given' do
        doc = render_scene(state: :processing)
        thumbnail = doc.at_css('[data-scene-script-target="thumbnail"]')
        expect(thumbnail).to be_present
        expect(thumbnail.at_css('img')['src']).to include('scene-script-processing')
      end

      it 'uses a caller-supplied spinner_url instead of the default' do
        doc = render_scene(state: :processing, spinner_url: '/custom-spinner.gif')
        thumbnail = doc.at_css('[data-scene-script-target="thumbnail"]')
        expect(thumbnail.at_css('img')['src']).to eq('/custom-spinner.gif')
      end

      it 'wires the resolved spinner_url onto the Stimulus controller so the JS optimistic transition matches' do
        doc = render_scene(state: :default, spinner_url: '/custom-spinner.gif')
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['data-scene-script-spinner-url-value']).to eq('/custom-spinner.gif')
      end

      it 'disables the textarea' do
        doc = render_scene(state: :processing)
        expect(doc.at_css('textarea')['disabled']).to eq('disabled')
      end

      it 'does not show the Approve action' do
        doc = render_scene(state: :processing)
        expect(doc.at_css('[data-scene-script-target="approveAction"]')).to be_nil
      end
    end

    describe 'generated state' do
      it 'renders the thumbnail image' do
        doc = render_scene(state: :generated, thumbnail_url: '/thumb.jpg')
        img = doc.at_css('[data-scene-script-target="thumbnail"] img')
        expect(img).to be_present
        expect(img['src']).to include('/thumb.jpg')
      end

      it 'makes the textarea readonly, not disabled' do
        doc = render_scene(state: :generated, thumbnail_url: '/thumb.jpg')
        textarea = doc.at_css('textarea')
        expect(textarea['readonly']).to eq('readonly')
        expect(textarea['disabled']).to be_nil
      end

      it 'wires the click-to-edit action on the script wrapper' do
        doc = render_scene(state: :generated, thumbnail_url: '/thumb.jpg')
        expect(doc.at_css('[data-action="click->scene-script#enterEdit"]')).to be_present
      end

      it 'omits the expand icon when previewable is false' do
        doc = render_scene(state: :generated, thumbnail_url: '/thumb.jpg', previewable: false)
        expect(doc.at_css('[data-action="click->scene-script#openPreview"]')).to be_nil
      end

      it 'shows the expand icon and preview modal when previewable is true' do
        doc = render_scene(
          state: :generated, thumbnail_url: '/thumb.jpg', previewable: true, video_url: '/video.mp4'
        )
        expect(doc.at_css('[data-action="click->scene-script#openPreview"]')).to be_present
        modal = doc.at_css('[data-scene-script-target="previewModal"]')
        expect(modal).to be_present
        expect(modal.at_css('video')['src']).to eq('/video.mp4')
      end
    end

    describe 'disabled state' do
      it 'applies opacity and pointer-events classes to the wrapper' do
        doc = render_scene(state: :disabled)
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['class']).to include('opacity-40')
        expect(root['class']).to include('pointer-events-none')
      end

      it 'marks the disabled value as true' do
        doc = render_scene(state: :disabled)
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['data-scene-script-disabled-value']).to eq('true')
      end

      it 'renders no thumbnail when thumbnail_url is absent' do
        doc = render_scene(state: :disabled)
        expect(doc.at_css('[data-scene-script-target="thumbnail"]')).to be_nil
      end

      it 'renders a muted thumbnail when thumbnail_url is present' do
        doc = render_scene(state: :disabled, thumbnail_url: '/thumb.jpg')
        expect(doc.at_css('[data-scene-script-target="thumbnail"] img')).to be_present
      end

      it 'makes the textarea readonly even without a thumbnail_url' do
        doc = render_scene(state: :disabled)
        expect(doc.at_css('textarea')['readonly']).to eq('readonly')
      end

      it 'does not show the Approve action even without a thumbnail_url' do
        doc = render_scene(state: :disabled)
        expect(doc.at_css('[data-scene-script-target="approveAction"]')).to be_nil
      end
    end

    describe 'edit actions' do
      it 'renders the Cancel and Regenerate buttons hidden by default' do
        doc = render_scene(state: :generated, thumbnail_url: '/thumb.jpg')
        edit_actions = doc.at_css('[data-scene-script-target="editActions"]')
        expect(edit_actions['class']).to include('hidden')
        expect(edit_actions.text).to include('Cancel')
        expect(edit_actions.text).to include('Regenerate')
      end
    end

    describe 'Approve/Regenerate submission' do
      it 'renders Approve as a real form POST to approve_url' do
        doc = render_scene(approve_url: '/scenes/1/approve')
        form = doc.at_css('[data-scene-script-target="approveAction"] form')
        expect(form['action']).to eq('/scenes/1/approve')
        expect(form['method']).to eq('post')
        expect(form.at_css('button[type="submit"]')).to be_present
      end

      it 'seeds the Approve form with a hidden script field' do
        doc = render_scene(approve_url: '/scenes/1/approve', script: 'Hello world')
        hidden = doc.at_css('[data-scene-script-target="approveAction"] input[name="script"]')
        expect(hidden['value']).to eq('Hello world')
      end

      it 'wires syncScript on the Approve form so live edits are captured on submit' do
        doc = render_scene(approve_url: '/scenes/1/approve')
        form = doc.at_css('[data-scene-script-target="approveAction"] form')
        expect(form['data-action']).to eq('submit->scene-script#syncScript')
      end

      it 'disables the Approve submit button when approve_url is absent' do
        doc = render_scene(approve_url: nil)
        button = doc.at_css('[data-scene-script-target="approveAction"] button[type="submit"]')
        expect(button['disabled']).to eq('disabled')
      end

      it 'renders Regenerate as a real form POST to regenerate_url' do
        doc = render_scene(regenerate_url: '/scenes/1/regenerate')
        form = doc.at_css('[data-scene-script-target="editActions"] form')
        expect(form['action']).to eq('/scenes/1/regenerate')
        expect(form['method']).to eq('post')
      end

      it 'seeds the Regenerate form with a hidden script field' do
        doc = render_scene(regenerate_url: '/scenes/1/regenerate', script: 'Hello world')
        hidden = doc.at_css('[data-scene-script-target="editActions"] input[name="script"]')
        expect(hidden['value']).to eq('Hello world')
      end

      it 'disables the Regenerate submit button when regenerate_url is absent' do
        doc = render_scene(regenerate_url: nil)
        button = doc.at_css('[data-scene-script-target="editActions"] button[type="submit"]')
        expect(button['disabled']).to eq('disabled')
      end
    end

    describe 'html_options' do
      it 'merges a caller-supplied class onto the wrapper' do
        doc = render_scene(html_options: { class: 'extra-class' })
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['class']).to include('extra-class')
      end

      it 'merges caller-supplied data attributes onto the wrapper' do
        doc = render_scene(html_options: { data: { testid: 'scene-1' } })
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['data-testid']).to eq('scene-1')
      end

      it 'does not let a caller-supplied data[:controller] override the Stimulus wiring' do
        doc = render_scene(html_options: { data: { controller: 'something-else' } })
        expect(doc.at_css('[data-controller="scene-script"]')).to be_present
        expect(doc.at_css('[data-controller="something-else"]')).to be_nil
      end

      it 'does not let a caller-supplied data value key override the resolved approve_url' do
        doc = render_scene(
          approve_url: '/real-approve',
          html_options: { data: { scene_script_approve_url_value: '/fake-approve' } }
        )
        root = doc.at_css('[data-controller="scene-script"]')
        expect(root['data-scene-script-approve-url-value']).to eq('/real-approve')
      end
    end
  end
end
