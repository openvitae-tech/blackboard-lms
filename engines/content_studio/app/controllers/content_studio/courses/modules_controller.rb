# frozen_string_literal: true

module ContentStudio
  module Courses
    class ModulesController < ApplicationController
      def destroy
        ApiClient.delete_module(params[:id], course_id: params[:course_id])
        flash[:notice] = t('.success')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::ResourceNotFound
        flash[:alert] = t('.not_found')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::BadRequestError
        flash[:alert] = t('.locked')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::Error
        flash[:alert] = t('.error')
        redirect_to course_structure_path(id: params[:course_id])
      end

      def bulk_destroy_lessons
        Array(params[:lesson_ids]).each do |lesson_id|
          ApiClient.delete_lesson(lesson_id, course_id: params[:course_id])
        end
        flash[:notice] = t('.success')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::ResourceNotFound
        flash[:alert] = t('.not_found')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::BadRequestError
        flash[:alert] = t('.locked')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::Error
        flash[:alert] = t('.error')
        redirect_to course_structure_path(id: params[:course_id])
      end
    end
  end
end
