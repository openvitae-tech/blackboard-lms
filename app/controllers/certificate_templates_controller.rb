# frozen_string_literal: true

class CertificateTemplatesController < ApplicationController
  before_action :set_learning_partner
  before_action :set_certificate_template, only: %i[update confirm_destroy destroy]

  def new
    authorize :certificate_template
    @certificate_template = @learning_partner.certificate_templates.new
  end

  def index
    authorize :certificate_template
    @certificate_templates = @learning_partner.certificate_templates.includes([:html_file_attachment])
  end

  def create
    authorize :certificate_template

    service = CreateCertificateTemplateService.instance
    @certificate_template = service.generate(@learning_partner, certificate_template_params)
    if @certificate_template.errors.any?
      render :new, status: :unprocessable_entity
    elsif @certificate_template.save
      redirect_to learning_partner_certificate_templates_path(@learning_partner),
                notice: t("resource.created", resource_name: "Certificate Template")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @certificate_template
    if @certificate_template.update(certificate_template_params)
      redirect_to learning_partner_certificate_templates_path(@learning_partner), notice: t("resource.updated", resource_name: "Certificate Template")
    else
      flash[:error] = @certificate_template.errors.full_messages.to_sentence
      flash.discard
    end
  end

  def confirm_destroy
    authorize @certificate_template
  end

  def destroy
    authorize @certificate_template
    @certificate_template.destroy!
    flash[:success] = t("resource.deleted", resource_name: "Certificate template")
    flash.discard
  end

  private

  def set_learning_partner
    @learning_partner = LearningPartner.find(params[:learning_partner_id])
  end

  def certificate_template_params
    params.require(:certificate_template).permit(:name, :active, :template_zip)
  end

  def set_certificate_template
    @certificate_template = @learning_partner.certificate_templates.find(params[:id])
  end
end
