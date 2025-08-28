# frozen_string_literal: true

class CertificateTemplatesController < ApplicationController
  before_action :set_learning_partner
  before_action :set_certificate_template, only: %i[update confirm_destroy destroy]

  def new
    @certificate_template = @learning_partner.certificate_templates.new
  end

  def index
    @certificate_templates = @learning_partner.certificate_templates
  end

  def create
    @certificate_template = @learning_partner.certificate_templates.new(certificate_template_params)
    if @certificate_template.save
      redirect_to learning_partner_certificate_templates_path(@learning_partner), notice: t("resource.created", resource_name: "Certificate Template")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @certificate_template.update!(certificate_template_params)
    redirect_to learning_partner_certificate_templates_path(@learning_partner), notice: t("resource.updated", resource_name: "Certificate Template")
  end

  def confirm_destroy
    render
  end

  def destroy
    @certificate_template.destroy!
    flash[:success] = t("resource.deleted", resource_name: "Program")
    flash.discard
  end

  private

  def set_learning_partner
    @learning_partner = LearningPartner.find(params[:learning_partner_id])
  end

  def certificate_template_params
    params.require(:certificate_template).permit(:name, :html_content, :active)
  end

  def set_certificate_template
    @certificate_template = @learning_partner.certificate_templates.find(params[:id])
  end
end
