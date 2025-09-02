# frozen_string_literal: true

module MembersHelper
  def member_menu_items(user)
    [
      deactivate_item(user),
      activate_item(user),
      delete_item(user),
      change_team_item(user)
    ]
  end

  private

  def deactivate_item(user)
    MenuComponentHelper::MenuItem.new(
      label: 'Deactivate',
      url: deactivate_member_path(user),
      type: :link,
      options: { data: { turbo_frame: 'modal' } },
      visible: policy(user).deactivate?
    )
  end

  def activate_item(user)
    MenuComponentHelper::MenuItem.new(
      label: 'Activate',
      url: activate_member_path(user),
      type: :link,
      options: { data: { turbo_frame: 'modal' } },
      visible: policy(user).activate?
    )
  end

  def delete_item(user)
    MenuComponentHelper::MenuItem.new(
      label: 'Delete',
      url: member_path,
      type: :link,
      extra_classes: 'text-danger',
      options: { data: { turbo_method: :delete, turbo_confirm: 'Are you sure want to delete?' } },
      visible: policy(user).destroy?
    )
  end

  def change_team_item(user)
    MenuComponentHelper::MenuItem.new(
      label: 'Change team',
      url: change_team_member_path,
      type: :link,
      options: { data: { turbo_frame: 'modal' } },
      visible: policy(user).change_team?
    )
  end
end
