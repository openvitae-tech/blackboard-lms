# frozen_string_literal: true

ContentStudio.authorization_callback = ->(user) { user.privileged_user? }
