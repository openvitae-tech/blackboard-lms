# frozen_string_literal: true

module Errors
  class InvalidEnrollmentError < StandardError; end
  class IllegalAccessError < StandardError; end
  class IllegalInviteError < StandardError; end
  class InvalidNotificationType < StandardError; end
  class IllegalUserState < StandardError; end
  class IllegalPartnerState < StandardError; end

  class IllegalSearchContext < StandardError; end
end
