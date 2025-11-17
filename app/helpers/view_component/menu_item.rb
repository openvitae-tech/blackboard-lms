# frozen_string_literal: true

module ViewComponent
  MenuItem = Struct.new(
    :label,
    :url,
    :type,
    :options,
    :extra_classes,
    keyword_init: true
  )
end
