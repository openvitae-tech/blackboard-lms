class RemoveHtmlContentColumnFromCertificateTemplates < ActiveRecord::Migration[8.0]
  def change
    remove_column :certificate_templates, :html_content
  end
end
