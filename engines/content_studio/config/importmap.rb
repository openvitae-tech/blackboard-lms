# frozen_string_literal: true

pin_all_from File.expand_path('../app/javascript/content_studio/controllers', __dir__),
             under: 'controllers',
             to: 'content_studio/controllers'

pin '@lottiefiles/lottie-player', to: 'https://esm.sh/@lottiefiles/lottie-player'
