require 'rails_helper'

RSpec.describe Courses::FilterService do
  describe 'with search term' do
    before do
      title = 'My best course'
      @published1 = create :course, :published, title: title
      @published2 = create :course, :published, title: 'Other title'
      @unpublished = create :course, :unpublished, title: title
    end

    let(:search_context) {
      SearchContext.new(
        context: SearchContext::COURSE_LISTING,
        term: 'best'
      )
    }

    describe 'by admin user' do
      let(:admin) { create(:user, role: :admin) }

      it 'filters all courses using search term' do
        service = Courses::FilterService.new(admin, search_context)
        result = service.filter
        expect(result.records.count).to eq(2)
        expect(result.records).to eq([@unpublished, @published1])
      end
    end

    describe 'by non admin user' do
      let(:user) { create(:user, role: :manager) }

      it 'filters published courses using search term' do
        service = Courses::FilterService.new(user, search_context)
        result = service.filter
        expect(result.records.count).to eq(1)
        expect(result.records).to eq([@published1])
      end
    end
  end

  describe 'filters courses using tags' do

    let(:level_tags) { create_list(:tag, 3, tag_type: :level) }
    let(:category_tags) { create_list(:tag, 3) }

    before do
      @unpublished = create :course, :unpublished, tag_ids: [level_tags[0].id, category_tags[0].id]
      @published1 = create :course, :published, tag_ids: [level_tags[0].id, category_tags[0].id]
      @published2 = create :course, :published, tag_ids: [level_tags[1].id, category_tags[1].id]
      @published3 = create :course, :published, tag_ids: [level_tags[2].id, category_tags[2].id]
    end

    describe 'by admin user' do
      let(:admin) { create(:user, role: :admin) }

      let(:search_context) {
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [level_tags[0].name, category_tags[0].name]
        )
      }

      it 'filters the courses using tags and includes unpublished courses' do
        service = Courses::FilterService.new(admin, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published1, @unpublished])
      end
    end

    describe 'by non admin user' do
      let(:user) { create(:user, role: :manager) }

      let(:search_context) {
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [level_tags[0].name, category_tags[0].name]
        )
      }

      it 'filters the courses using tags' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(1)
        expect(results.records).to eq([@published1])
      end
    end

    describe 'with multiple level tags' do
      let(:user) { create(:user, role: :manager) }

      let(:search_context) {
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [level_tags[0].name, level_tags[1].name]
        )
      }

      it 'courses of all selected levels will be returned' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published2, @published1])
      end
    end

    describe 'with multiple category tags' do
      let(:user) { create(:user, role: :manager) }

      let(:search_context) {
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [category_tags[0].name, category_tags[1].name]
        )
      }

      it 'courses of all selected categories will be returned' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published2, @published1])
      end
    end

    describe 'with multiple category tags and single level' do
      let(:user) { create(:user, role: :manager) }

      let(:search_context) {
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [category_tags[0].name, category_tags[1].name, level_tags[0].name]
        )
      }

      it 'courses matching both categories and level will be returned' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(1)
        expect(results.records).to eq([@published1])
      end
    end

    describe 'for both multiple categories and multiple levels' do
      let(:user) { create(:user, role: :manager) }

      let(:search_context) {
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [category_tags[0].name,
                 category_tags[1].name,
                 category_tags[2].name,
                 level_tags[0].name,
                 level_tags[1].name]
        )
      }

      it 'select all courses with having any matching combination of categories and tags' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published2, @published1])
      end

    end

  end

  describe 'filters for context team_assing' do
    it 'filters out already assigned courses' do

    end
  end

  describe 'filters for context user_assign' do
    it 'filters out already assigned courses' do

    end
  end
end