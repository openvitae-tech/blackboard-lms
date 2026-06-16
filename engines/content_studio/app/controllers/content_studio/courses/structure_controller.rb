# frozen_string_literal: true

module ContentStudio
  module Courses
    class StructureController < ApplicationController
      def show
        @structure = ApiClient.course_structure(params[:id])
      rescue Faraday::ResourceNotFound
        redirect_to root_path
      end

      def save
        ApiClient.save_course(params[:id])
        flash[:notice] = t('.success')
        redirect_to course_structure_path(id: params[:id])
      rescue Faraday::Error
        flash[:alert] = t('.error')
        redirect_to course_structure_path(id: params[:id])
      end

      def discard
        ApiClient.discard_course(params[:id])
        redirect_to root_path
      rescue Faraday::BadRequestError
        flash[:alert] = t('content_studio.courses.discard.locked')
        redirect_to course_structure_path(id: params[:id])
      end
    end
  end
end
