# frozen_string_literal: true

module LearningPartnersHelper
  def learning_partner_menu_items(learning_partner)
    [
      edit_partner_item(learning_partner),
      activate_partner_item(learning_partner),
      payment_plan_item(learning_partner),
      impersonate_partner_item(learning_partner),
      deactivate_partner_item(learning_partner)
    ].compact
  end

  private

  def edit_partner_item(learning_partner)
    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('button.edit'),
      url: edit_learning_partner_path(learning_partner),
      type: :link
    )
  end

  def activate_partner_item(learning_partner)
    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('learning_partner.activate'),
      url: activate_learning_partner_path(learning_partner),
      type: :link,
      options: {
        data: {
          turbo_method: :put,
          turbo_confirm: 'Are you sure want to activate this partner?'
        }
      },
      visible: policy(learning_partner).activate?
    )
  end

  def payment_plan_item(learning_partner)
    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('learning_partner.payment_plan.modify'),
      url: edit_learning_partner_payment_plan_path(learning_partner),
      type: :link,
      options: { data: { turbo_frame: 'modal' } }
    )
  end

  def impersonate_partner_item(learning_partner)
    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('impersonation.impersonate'),
      url: impersonation_path(id: learning_partner.id),
      type: :button,
      visible: policy(learning_partner).deactivate?
    )
  end

  def deactivate_partner_item(learning_partner)
    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('learning_partner.block'),
      url: deactivate_learning_partner_path(learning_partner),
      type: :link,
      extra_classes: 'text-danger',
      options: {
        data: {
          turbo_method: :put,
          turbo_confirm: 'Are you sure want to de-activate this partner?'
        }
      },
      visible: policy(learning_partner).deactivate?
    )
  end
end
