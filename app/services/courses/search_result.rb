# frozen_string_literal: true

module Courses
  class SearchResult
    def initialize(results, search_context)
      @results = results
      @search_context = search_context
    end

    def records
      @results
    end

    delegate :count, to: :@results

    def size
      count
    end
  end
end
