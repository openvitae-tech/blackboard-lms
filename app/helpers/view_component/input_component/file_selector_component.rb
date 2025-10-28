# frozen_string_literal: true

module ViewComponent
  module InputComponent
    class FileSelectorComponent
      include ViewComponent::ComponentHelper

      FILE_SELECTOR_TYPES = %w[image document video].freeze

      attr_accessor :form, :name, :label, :support_text,
                    :support_text_two, :error, :disabled, :html_options, :type

      def initialize(type:, form: nil, name: nil, label: nil,
                     support_text: nil, support_text_two: nil, error: nil, disabled: false, html_options: {})
        raise "Invalid or missing file type: #{type}" unless FILE_SELECTOR_TYPES.include?(type)

        error_message = resolve_error(form, name, error)

        self.form = form
        self.name = name
        self.label = label
        self.support_text = support_text
        self.support_text_two = support_text_two
        self.error = error_message
        self.disabled = disabled
        self.html_options = html_options
        self.type = type
      end

      def accepted_types
        case type
        when 'image'
          'image/*'
        when 'document'
          '.csv,.pdf,.doc,.docx'
        when 'video'
          'video/*,.mp4,.mov,.avi,.mkv'
        else
          '*/*'
        end
      end

      def wrapper_style
        base = ['file-selector-component-base radius-lg md:radius-xl']

        color_style =
          if disabled
            'textarea-disabled-state pointer-events-none cursor-not-allowed'
          elsif error.present?
            'border-danger'
          else
            'border-primary'
          end

        class_list(base, color_style)
      end

      def label_style
        base = ['general-text-sm-normal px-1']

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-letter-color-light'
          end

        class_list(base, color_style)
      end

      def preview_style
        base = ['file-selector-preview']

        class_list(base)
      end

      def upload_icon_style
        base = ['file-selector-upload-icon']

        color_style =
          if disabled
            'fill-disabled-color'
          elsif error.present?
            'fill-danger'
          else
            'fill-primary'
          end

        class_list(base, color_style)
      end

      def choose_file_style
        base = ['general-text-md-normal ']

        color_style =
          if disabled
            'text-disabled-color'
          else
            'text-primary'
          end

        class_list(base, color_style)
      end

      def support_text_style
        base = ['file-selector-support-text general-text-sm-normal']

        color_style =
          if disabled
            'text-disabled-color'
          elsif error.present?
            'text-danger-dark'
          else
            'text-slate-grey-50'
          end

        class_list(base, color_style)
      end
    end
  end
end
