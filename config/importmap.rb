# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'flowbite', to: 'https://cdnjs.cloudflare.com/ajax/libs/flowbite/2.3.0/flowbite.turbo.min.js'
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.esm.js'
pin 'chartkick', to: 'chartkick.js'
pin 'Chart.bundle', to: 'Chart.bundle.js'
pin '@rails/activestorage', to: 'activestorage.esm.js'
pin_all_from 'app/javascript/store', under: 'store', to: 'store'
pin_all_from 'app/javascript/utils', under: 'utils', to: 'utils'
pin '@rails/actioncable', to: 'actioncable.esm.js'
pin_all_from 'app/javascript/channels', under: 'channels', to: 'channels'
pin 'swiper', to: 'https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.mjs'
