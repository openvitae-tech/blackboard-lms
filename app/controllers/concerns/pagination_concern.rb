# frozen_string_literal: true

module PaginationConcern
  def get_current_page(record:, page:, per_page_count: 10)
    current_page = page.to_i
    current_page = 1 if current_page.zero?

    courses = record.page(current_page).per(per_page_count)
    if courses.empty? && current_page > 1
      current_page - 1
    else
      current_page
    end
  end
end
