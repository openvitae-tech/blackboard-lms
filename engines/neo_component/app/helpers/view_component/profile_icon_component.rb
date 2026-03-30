# frozen_string_literal: true

module ViewComponent
  module ProfileIconComponent
    class ProfileIconComponent
      include ViewComponent::ComponentHelper

      PROFILE_ICON_SIZES = %w[sm md lg].freeze

      PROFILE_ICON_SIZE_STYLES = {
        sm: 'profile-icon-sm',
        md: 'profile-icon-md',
        lg: 'profile-icon-lg'
      }.freeze

      attr_accessor :letter, :size

      def initialize(letter:, size: 'md')
        raise "Incorrect profile icon size: #{size}" unless PROFILE_ICON_SIZES.include?(size)

        self.letter = (letter.presence || 'U').to_s[0].upcase
        self.size = size
      end

      def profile_icon_style
        base = ['profile-icon-base']
        size_style = PROFILE_ICON_SIZE_STYLES[size.to_sym]

        class_list(base, size_style)
      end
    end

    def profile_icon_component(letter:, size: 'md')
      normalized_letter = (letter.presence || 'U').to_s[0]

      profile_icon =
        ProfileIconComponent.new(
          letter: normalized_letter,
          size:
        )

      render partial: 'view_components/profile_icon_component/profile_icon',
             locals: { profile_icon: }
    end
  end
end
