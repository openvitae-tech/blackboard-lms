# frozen_string_literal: true

class ClassroomKitsController < ApplicationController
  before_action :authenticate_user!
  before_action { @active_nav = 'content' }
  before_action :set_kit, only: %i[show download download_all]

  def index
    authorize :classroom_kit, :index?
    @kits = ClassroomKit.where(learning_partner_id: current_user.learning_partner_id)
                        .order(created_at: :desc)
  end

  def show
    authorize @kit, :show?
    @components = @kit.classroom_kit_components
  end

  def download
    authorize @kit, :show?
    data = neo_ai_client.get_kit(@kit.neo_ai_kit_id)
    component = Array(data['components']).find { |c| c['id'] == params[:component_id] }
    return head :not_found if component.nil? || component['download_url'].blank?

    redirect_to component['download_url'], allow_other_host: true
  rescue Faraday::Error => e
    Rails.logger.warn("[ClassroomKits] download failed: #{e.message}")
    flash[:alert] = t('.failed')
    redirect_to classroom_kit_path(@kit)
  end

  def download_all
    authorize @kit, :show?
    data = neo_ai_client.get_kit(@kit.neo_ai_kit_id)
    components = Array(data['components']).select { |c| c['download_url'].present? }
    return head :not_found if components.empty?

    zip_data = build_zip(components)
    kit_name = @kit.title.presence&.parameterize || 'classroom-kit'
    send_data zip_data.string, filename: "#{kit_name}.zip", type: 'application/zip', disposition: 'attachment'
  rescue Faraday::Error => e
    Rails.logger.warn("[ClassroomKits] download_all failed: #{e.message}")
    flash[:alert] = t('classroom_kits.download.failed')
    redirect_to classroom_kit_path(@kit)
  end

  EXTENSIONS = {
    'application/pdf' => 'pdf',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx'
  }.freeze

  private

  def build_zip(components)
    conn = Faraday.new(request: { open_timeout: 5, timeout: 60 })
    Zip::OutputStream.write_buffer do |zip|
      components.each do |component|
        file = conn.get(component['download_url'])
        unless file.success?
          Rails.logger.warn("[ClassroomKits] skipping #{component['id']} — #{file.status}")
          next
        end

        content_type = file.headers['content-type'] || 'application/octet-stream'
        ext = EXTENSIONS[content_type.split(';').first.strip] || 'bin'
        zip.put_next_entry("#{component['type'].parameterize}-#{component['id']}.#{ext}")
        zip.write(file.body)
      end
    end
  end

  def set_kit
    @kit = ClassroomKit.find_by!(id: params[:id], learning_partner_id: current_user.learning_partner_id)
  end

  def neo_ai_client
    partner_id = if Rails.env.development?
                   NEO_AI_PARTNER_ID
                 else
                   OpenSSL::HMAC.hexdigest('SHA256', NEO_AI_PARTNER_HMAC_SECRET,
                                           current_user.learning_partner_id.to_s)
                 end
    NeoAi::Client.new(partner_id: partner_id)
  end
end
