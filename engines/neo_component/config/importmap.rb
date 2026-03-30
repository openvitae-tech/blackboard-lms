# frozen_string_literal: true

pin_all_from File.expand_path('../app/javascript/neo_components/controllers', __dir__),
             under: 'controllers',
             to: 'neo_components/controllers'

pin 'swiper', to: 'https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs'
