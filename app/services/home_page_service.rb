# frozen_string_literal: true

class HomePageService
  include Singleton

  CONFIG = {
    banner: { enabled: false, order: 0 },
    programs: { enabled: true, order: 1 },
    continue: { enabled: true, order: 2 },
    categories: { enabled: true, order: 3, tags: ['Front Office', 'Housekeeping'] }
  }.freeze

  def build_data_for(user)
    data = {}
    CONFIG.sort_by { |_, section| section[:order] }.each do |key, section|
      next unless section[:enabled]

      data[key] = send("build_#{key}", user)
    end
    data
  end

  private

  def build_banner(user); end

  def build_programs(user)
    user.learning_partner.programs.includes(:program_courses, :program_users)
  end

  def build_continue(user)
    ctx = SearchContext.new(context: SearchContext::HOME_PAGE, type: SearchContext::INCOMPLETE)
    Courses::FilterService.new(user, ctx).filter.records
  end

  def build_categories(user)
    ctx = SearchContext.new(context: SearchContext::HOME_PAGE, tags: CONFIG[:categories][:tags])
    courses_in_categories = Courses::FilterService.new(user, ctx).filter.records.includes(:tags, :banner_attachment)
    courses = {}

    courses_in_categories.each do |course|
      category_tag = course.tags.find { |tag| tag.tag_type == 'category' }
      next unless category_tag

      courses[category_tag.name] ||= []
      courses[category_tag.name] << course
    end
    courses
  end
end
