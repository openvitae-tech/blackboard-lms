module TagsHelper
  def tag_list
    Tag.tag_types.transform_keys { |key| key.capitalize }
  end
end
