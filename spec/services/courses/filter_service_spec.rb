# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::FilterService do
  let(:learning_partner) { create :learning_partner }

  describe 'with search term' do
    before do
      title = 'My best course'
      @published1 = create :course, :published, title: title
      @published2 = create :course, :published, title: 'Other title'
      @unpublished = create :course, :unpublished, title: title
    end

    let(:search_context) do
      SearchContext.new(
        context: SearchContext::COURSE_LISTING,
        term: 'best'
      )
    end

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
      let(:user) { create(:user, role: :manager, learning_partner:) }

      it 'filters published courses using search term' do
        service = Courses::FilterService.new(user, search_context)
        result = service.filter
        expect(result.records.count).to eq(1)
        expect(result.records).to eq([@published1])
      end

      it 'list only public courses for the user whose learning partner is public' do
        learning_partner = create(:learning_partner, is_public: true)
        user_one = create(:user, :learner, learning_partner:)
        @published1.update!(visibility: 'public')

        search_context = SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          term: ''
        )
        service = Courses::FilterService.new(user_one, search_context)
        result = service.filter

        expect(result.records.pluck(:id)).to eq([@published1.id])
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
      @published3 = create :course, :published, tag_ids: [level_tags[2].id, category_tags[1].id, category_tags[2].id]
    end

    describe 'by admin user' do
      let(:admin) { create(:user, role: :admin) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [level_tags[0].name, category_tags[0].name]
        )
      end

      it 'filters the courses using tags and includes unpublished courses' do
        service = Courses::FilterService.new(admin, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published1, @unpublished])
      end
    end

    describe 'by non admin user' do
      let(:user) { create(:user, role: :manager, learning_partner:) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [level_tags[0].name, category_tags[0].name]
        )
      end

      it 'filters the courses using tags' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(1)
        expect(results.records).to eq([@published1])
      end
    end

    describe 'with multiple level tags' do
      let(:user) { create(:user, role: :manager, learning_partner:) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [level_tags[0].name, level_tags[1].name]
        )
      end

      it 'courses of all selected levels will be returned' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published2, @published1])
      end
    end

    describe 'with multiple category tags' do
      let(:user) { create(:user, role: :manager, learning_partner:) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [category_tags[0].name, category_tags[1].name]
        )
      end

      it 'courses of all selected categories will be returned' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(3)
        expect(results.records).to eq([@published3, @published2, @published1])
      end
    end

    describe 'with multiple category tags and single level' do
      let(:user) { create(:user, role: :manager, learning_partner:) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [category_tags[0].name, category_tags[1].name, level_tags[0].name]
        )
      end

      it 'courses matching both categories and level will be returned' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(1)
        expect(results.records).to eq([@published1])
      end
    end

    describe 'for both multiple categories and multiple levels' do
      let(:user) { create(:user, role: :manager, learning_partner:) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          tags: [category_tags[0].name,
                 category_tags[1].name,
                 category_tags[2].name,
                 level_tags[0].name,
                 level_tags[1].name]
        )
      end

      it 'select all courses with having any matching combination of categories and tags' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(2)
        expect(results.records).to eq([@published2, @published1])
      end
    end

    describe 'for multiple categories, multiple levels and term' do
      let(:user) { create(:user, role: :manager, learning_partner:) }

      let(:search_context) do
        SearchContext.new(
          context: SearchContext::COURSE_LISTING,
          term: @published2.title,
          tags: [category_tags[0].name,
                 category_tags[1].name,
                 category_tags[2].name,
                 level_tags[0].name,
                 level_tags[1].name]
        )
      end

      it 'select all courses with having any matching combination of categories and tags' do
        service = Courses::FilterService.new(user, search_context)
        results = service.filter
        expect(results.records.count).to eq(1)
        expect(results.records).to eq([@published2])
      end
    end
  end

  describe 'filters for context team_assign' do
    before do
      @course1 = create :course, :published
      @course2 = create :course, :published
      @team = create :team
      @manager = create :user, :learner, team: @team
      @learner = create :user, :learner, team: @team
      @course1.enroll_team!(@team, @manager)
    end

    let(:search_context) do
      SearchContext.new(
        context: SearchContext::TEAM_ASSIGN,
        options: {
          team: @team
        }
      )
    end

    it 'filters out already assigned/enrolled courses' do
      service = Courses::FilterService.new(@manager, search_context)
      results = service.filter
      expect(results.records.count).to eq(1)
      expect(results.records).to eq([@course2])
    end
  end

  describe 'filters for context user_assign' do
    before do
      @course1 = create :course, :published
      @course2 = create :course, :published
      @team = create :team
      @manager = create :user, :learner, team: @team
      @learner = create :user, :learner, team: @team
      @course1.enroll!(@learner, @manager)
    end

    let(:search_context) do
      SearchContext.new(
        context: SearchContext::USER_ASSIGN,
        options: {
          user: @learner
        }
      )
    end

    it 'filters out already assigned/enrolled courses' do
      service = Courses::FilterService.new(@manager, search_context)
      results = service.filter
      expect(results.records.count).to eq(1)
      expect(results.records).to eq([@course2])
    end
  end

  describe 'filter for context program' do
    before do
      @learning_partner = create :learning_partner
      @manager = create :user, :learner, team: @team

      @course1 = create :course, :published
      @course2 = create :course, :published
      @program = create :program, courses: [@course1], learning_partner: @learning_partner
    end

    let(:search_context) do
      SearchContext.new(
        context: SearchContext::PROGRAM,
        options: {
          program: @program
        }
      )
    end

    it 'filter out courses not assigned to the program' do
      service = Courses::FilterService.new(@manager, search_context)
      results = service.filter
      expect(results.records.pluck(:id)).to eq([@course2.id])
    end
  end
end
