# frozen_string_literal: true

module ViewComponent
  module ScriptReviewCardComponent
    VARIANTS = %w[default edit generated processing disabled_default disabled_generated].freeze

    class ScriptReviewCardComponent
      include ViewComponent::ComponentHelper

      attr_accessor :scene_number, :scene_total, :title, :script, :variant, :thumbnail_url

      def initialize(scene_number:, scene_total:, title:, script:,
                     variant: 'default', thumbnail_url: nil)
        raise ArgumentError, "Unknown variant: #{variant}" unless VARIANTS.include?(variant.to_s)

        self.scene_number  = scene_number
        self.scene_total   = scene_total
        self.title         = title
        self.script        = script
        self.variant       = variant.to_s
        self.thumbnail_url = thumbnail_url
      end

      def card_class
        base = 'bg-white border rounded-xl p-5 flex flex-col gap-4'
        edit? ? "#{base} border-2 border-primary" : "#{base} border-line-colour"
      end

      def title_class
        disabled? ? 'main-text-md-semibold text-disabled-color' : 'main-text-md-semibold text-letter-color'
      end

      def show_approve_button? = variant == 'default'
      def show_edit_buttons?   = edit?
      def show_thumbnail?      = %w[generated processing disabled_generated].include?(variant)
      def processing?          = variant == 'processing'
      def disabled?            = variant.start_with?('disabled')
      def edit?                = variant == 'edit'
      def textarea_disabled?   = %w[processing disabled_default disabled_generated].include?(variant)
    end

    def script_review_card_component(scene_number:, scene_total:, title:, script:,
                                     variant: 'default', thumbnail_url: nil)
      component = ScriptReviewCardComponent.new(
        scene_number:, scene_total:, title:, script:, variant:, thumbnail_url:
      )
      render partial: 'view_components/script_review_card_component/script_review_card',
             locals: { component: }
    end
  end
end
