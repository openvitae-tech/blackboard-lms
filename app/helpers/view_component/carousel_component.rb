# frozen_string_literal: true

module ViewComponent
  module CarouselComponent
    def carousel_component(cards:, loop: false, enable_in_small_devices: true)
      partial_path = 'view_components/carousel_component/carousel'
      render partial: partial_path, locals: { cards:, loop:, enable_in_small_devices: }
    end
  end
end
