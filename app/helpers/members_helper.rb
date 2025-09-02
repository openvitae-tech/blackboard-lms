# frozen_string_literal: true

module MembersHelper
  def member_menu_items(user)
    [
      MenuComponentHelper::MenuItem.new(
        label: 'Deactivate',
        url: deactivate_member_path(user),
        type: :link,
        options: { data: { turbo_frame: 'modal' } },
        visible: policy(user).deactivate?
      ),
      MenuComponentHelper::MenuItem.new(
        label: 'Activate',
        url: activate_member_path(user),
        type: :link,
        options: { data: { turbo_frame: 'modal' } },
        visible: policy(user).activate?
      ),
      MenuComponentHelper::MenuItem.new(
        label: 'Delete',
        url: member_path,
        type: :link,
        extra_classes: 'text-danger',
        options: { data: { turbo_method: :delete, turbo_confirm: 'Are you sure want to delete?' } },
        visible: policy(user).destroy?
      ),
      MenuComponentHelper::MenuItem.new(
        label: 'Change team',
        url: change_team_member_path,
        type: :link,
        options: { data: { turbo_frame: 'modal' } },
        visible: policy(user).change_team?
      )
    ]
  end
end
