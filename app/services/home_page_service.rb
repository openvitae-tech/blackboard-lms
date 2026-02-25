# frozen_string_literal: true

class HomePageService
  include Singleton

  CONFIG = {
    banner: { enabled: false, order: 0 },
    programs: { enabled: true, order: 1 },
    continue: { enabled: true, order: 2 },
    categories: { enabled: true, order: 3, tags: ['Front Office', 'Housekeeping'] }
  }.freeze

  attr_reader :user

  def self.build_data_for(user)
    @user = user
    data = {}
    CONFIG.sort_by { |_, section| section[:order] }.each do |key, section|
      next unless section[:enabled]

      data[key] = send("build_#{key}")
    end
    data
  end

  def self.build_banner; end

  def self.build_programs
    @user.learning_partner.programs
  end

  def self.build_continue
    ctx = SearchContext.new(context: SearchContext::HOME_PAGE, type: SearchContext::INCOMPLETE)
    Courses::FilterService.new(@user, ctx).filter.records
  end

  def self.build_categories
    ctx = SearchContext.new(context: SearchContext::HOME_PAGE, tags: CONFIG[:categories][:tags])
    courses_in_categories = Courses::FilterService.new(@user, ctx).filter.records
    courses = {}

    courses_in_categories.each do |course|
      category_tag = course.tags.find { |tag| tag.tag_type == 'category' }
      courses[category_tag.name] ||= []
      courses[category_tag.name] << course
    end
    courses
  end
end
