# frozen_string_literal: true

module LearningPartnersHelper
  def learning_partner_menu_items(learning_partner)
    [
      edit_partner_item(learning_partner),
      activate_partner_item(learning_partner),
      payment_plan_item(learning_partner),
      certificate_templates_item(learning_partner),
      impersonate_partner_item(learning_partner),
      deactivate_partner_item(learning_partner)
    ].compact
  end

  private

  def edit_partner_item(learning_partner)
    ViewComponent::MenuComponent::MenuItem.new(
      label: t('button.edit'),
      url: edit_learning_partner_path(learning_partner),
      type: :link,
      options: {
        data: { turbo_frame: 'modal' }
      }
    )
  end

  def activate_partner_item(learning_partner)
    return unless policy(learning_partner).activate?

    ViewComponent::MenuComponent::MenuItem.new(
      label: t('learning_partner.activate'),
      url: activate_learning_partner_path(learning_partner),
      type: :link,
      options: {
        data: {
          turbo_method: :put,
          turbo_confirm: t('confirmations.learning_partner.activate')
        }
      }
    )
  end

  def payment_plan_item(learning_partner)
    label_key =
      if learning_partner.payment_plan.present?
        'learning_partner.payment_plan.modify'
      else
        'learning_partner.payment_plan.create'
      end

    ViewComponent::MenuComponent::MenuItem.new(
      label: t(label_key),
      url: edit_learning_partner_payment_plan_path(learning_partner),
      type: :link,
      options: { data: { turbo_frame: 'modal' } }
    )
  end

  def certificate_templates_item(learning_partner)
    ViewComponent::MenuComponent::MenuItem.new(
      label: t('learning_partner.certificate_templates', default: 'Certificate templates'),
      url: learning_partner_certificate_templates_path(learning_partner.id),
      type: :link
    )
  end

  def impersonate_partner_item(learning_partner)
    return unless policy(learning_partner).deactivate?

    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('impersonation.impersonate'),
      url: impersonation_path(id: learning_partner.id),
      type: :button
    )
  end

  def deactivate_partner_item(learning_partner)
    return unless policy(learning_partner).deactivate?

    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('learning_partner.block'),
      url: deactivate_learning_partner_path(learning_partner),
      type: :link,
      extra_classes: 'text-danger',
      options: {
        data: {
          turbo_method: :put,
          turbo_confirm: t('confirmations.learning_partner.deactivate')
        }
      }
    )
  end
end
