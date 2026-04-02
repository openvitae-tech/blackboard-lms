# frozen_string_literal: true

module NeoComponents
  module Ui
    class TablesController < BaseController
      # Sample data for demonstration — no host-app models required
      SampleRow = Data.define(:id, :name, :type)

      def index
        @sample_rows = [
          SampleRow.new(id: 1, name: "Housekeeping", type: "Category"),
          SampleRow.new(id: 2, name: "Food Production", type: "Category"),
          SampleRow.new(id: 3, name: "Beginner", type: "Level"),
          SampleRow.new(id: 4, name: "Advanced", type: "Level")
        ]
      end
    end
  end
end
