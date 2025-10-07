# frozen_string_literal: true

class DirectUploadsController < ActiveStorage::DirectUploadsController
  protect_from_forgery with: :null_session

  before_action :authenticate_user!

  def create
    blob = ActiveStorage::Blob.create_before_direct_upload!(**upload_blob_attributes)

    render json: direct_upload_json(blob)
  end

  private

  def blob_args
    params
      .require(:blob)
      .permit(:filename, :byte_size, :checksum, :service_name, :content_type, metadata: {}).to_h.symbolize_keys
  end

  def upload_blob_attributes
    if external_video_hosting? && params[:service] == 'video'
      blob_args.merge(service_name: 's3_video_store')
    else
      blob_args
    end
  end
end
