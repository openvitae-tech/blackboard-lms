# frozen_string_literal: true

module ContentStudio
  module Courses
    class StructureController < ApplicationController
      def show
        @structure = ApiClient.course_structure(params[:id])
      end

      def save
        ApiClient.save_course(params[:id])
        redirect_to course_structure_path(id: params[:id])
      end

      def discard
        ApiClient.discard_course(params[:id])
        redirect_to root_path
      end
    end
  end
end
