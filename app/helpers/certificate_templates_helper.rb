# frozen_string_literal: true

module CertificateTemplatesHelper
  def certificate_template_menu_items(learning_partner, template)
    [
      deactivate_certificate_template_item(learning_partner, template),
      activate_certificate_template_item(learning_partner, template),
      delete_certificate_template_item(learning_partner, template)
    ].compact
  end

  private

  def activate_certificate_template_item(learning_partner, template)
    return if template.active?
    return if learning_partner.certificate_templates.exists?(active: true)

    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('learning_partner.certificate_template.activate', default: 'Activate'),
      url: learning_partner_certificate_template_path(learning_partner, template),
      type: :button,
      options: {
        method: :patch,
        params: { certificate_template: { active: true } }
      }
    )
  end

  def deactivate_certificate_template_item(learning_partner, template)
    return unless template.active?

    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('learning_partner.certificate_template.deactivate', default: 'Deactivate'),
      url: learning_partner_certificate_template_path(learning_partner, template),
      type: :button,
      options: {
        method: :patch,
        params: { certificate_template: { active: false } }
      }
    )
  end

  def delete_certificate_template_item(learning_partner, template)
    return if template.active?

    ViewComponent::MenuComponentHelper::MenuItem.new(
      label: t('button.delete', default: 'Delete'),
      url: confirm_destroy_learning_partner_certificate_template_path(learning_partner, template),
      type: :link,
      options: { data: { turbo_frame: 'modal' } },
      extra_classes: 'text-danger'
    )
  end
end
