# frozen_string_literal: true

module ViewComponent
  module Card
    module CertificateCardComponent
      def certificate_card_component(certificate:, thumbnail_url: nil)
        render partial: 'view_components/cards/certificate_card_component', locals: {
          has_thumbnail: resolve_has_thumbnail(certificate, thumbnail_url),
          thumbnail_url: resolve_thumbnail_url(certificate, thumbnail_url),
          course_title: certificate.course.title,
          download_path: resolve_download_path(certificate),
          share_path: resolve_share_path(certificate)
        }
      end

      private

      def resolve_has_thumbnail(certificate, thumbnail_url)
        return true if thumbnail_url.present?

        thumbnail = certificate.certificate_thumbnail
        thumbnail.respond_to?(:attached?) && thumbnail.attached? && thumbnail.blob.present?
      end

      def resolve_thumbnail_url(certificate, thumbnail_url)
        return thumbnail_url if thumbnail_url.present?

        thumbnail = certificate.certificate_thumbnail
        return unless thumbnail.respond_to?(:attached?) && thumbnail.attached?

        url_for(thumbnail)
      end

      def resolve_download_path(certificate)
        certificate.file.present? ? rails_blob_path(certificate.file, disposition: 'attachment') : '#'
      end

      def resolve_share_path(certificate)
        certificate.id.present? ? share_certificate_profile_path(certificate_id: certificate.id) : '#'
      end
    end
  end
end
