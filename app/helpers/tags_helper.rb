# frozen_string_literal: true

module TagsHelper
  def tag_list
    Tag.tag_types.transform_keys(&:capitalize)
  end
end
