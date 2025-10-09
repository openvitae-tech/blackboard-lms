# frozen_string_literal: true

module ViewComponent
  module ComponentHelper
    def class_list(base, *styles)
      base.concat(styles.compact)
      base.join(' ')
    end
  end
end
