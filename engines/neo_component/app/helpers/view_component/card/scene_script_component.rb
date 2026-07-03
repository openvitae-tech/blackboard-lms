# frozen_string_literal: true

module ViewComponent
  module Card
    module SceneScriptComponent
      SCENE_SCRIPT_STATES = %i[default processing generated disabled].freeze

      def scene_script_component(
        scene_number:,
        total_scenes:,
        title:,
        script:,
        state:,
        thumbnail_url: nil,
        video_url: nil,
        previewable: false,
        approve_url: nil,
        regenerate_url: nil,
        html_options: {}
      )
        state = state&.to_sym
        validate_scene_script_state!(state)

        show_thumbnail = state == :processing || thumbnail_url.present?

        render partial: 'view_components/cards/scene_script_component', locals: {
          scene_number:,
          total_scenes:,
          title:,
          script:,
          state:,
          thumbnail_url:,
          video_url:,
          previewable:,
          approve_url:,
          regenerate_url:,
          show_thumbnail:,
          show_header_action: !show_thumbnail,
          wrapper_html_options: scene_script_wrapper_html_options(state, approve_url, regenerate_url, html_options)
        }
      end

      private

      def validate_scene_script_state!(state)
        return if SCENE_SCRIPT_STATES.include?(state)

        raise ArgumentError, "state must be one of #{SCENE_SCRIPT_STATES.join(', ')}"
      end

      def scene_script_wrapper_html_options(state, approve_url, regenerate_url, html_options)
        classes = ['bg-white rounded-xl border border-line-colour p-5 flex flex-col gap-4 w-full']
        classes << 'opacity-40 pointer-events-none' if state == :disabled
        classes << html_options[:class]

        data = {
          controller: 'scene-script',
          scene_script_approve_url_value: approve_url,
          scene_script_regenerate_url_value: regenerate_url,
          scene_script_disabled_value: state == :disabled
        }.merge(html_options[:data] || {})

        html_options.except(:class, :data).merge(class: classes.compact.join(' '), data:)
      end
    end
  end
end
