# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchContext do
  describe 'A valid course listing search context' do
    let(:ctx) do
      SearchContext.new(
        context: SearchContext::COURSE_LISTING,
        term: 'My search term',
        tags: %w[beginner beverages],
        type: SearchContext::ANY
      )
    end

    it 'Create a new search context for course search' do
      expect(ctx).to be_valid
    end

    it 'is course_listing context' do
      expect(ctx).to be_course_listing
    end

    it 'is not any other context' do
      expect(ctx).not_to be_team_assign
      expect(ctx).not_to be_user_assign
      expect(ctx).not_to be_home_page
    end

    it 'is of any search type' do
      expect(ctx).to be_search_all_courses
    end

    it 'is not any search type' do
      expect(ctx).not_to be_search_enrolled_courses
      expect(ctx).not_to be_search_unenrolled_courses
    end

    it 'sets search tags' do
      expect(ctx.tags).to eq(%w[beginner beverages])
    end

    it 'sets search term' do
      expect(ctx.term).to eq('My search term')
    end
  end

  describe 'TEAM_ASSIGN search context' do
    it 'initializes a team assign search context' do
      expect(
        SearchContext.new(
          context: SearchContext::TEAM_ASSIGN,
          term: 'My search term',
          tags: %w[beginner beverages],
          type: SearchContext::ANY,
          options: { team: Team.new }
        )
      ).to be_valid
    end

    it 'trows error when creating a TEAM_ASSIGN search context without a team value' do
      expect do
        SearchContext.new(
          context: SearchContext::TEAM_ASSIGN,
          term: 'My search term',
          tags: %w[beginner beverages],
          type: SearchContext::ANY
        )
      end.to raise_error(Errors::IllegalSearchContext)
    end
  end

  describe 'USER_ASSIGN search context' do
    it 'initializes a user assign search context with User record as option' do
      expect(
        SearchContext.new(
          context: SearchContext::TEAM_ASSIGN,
          term: 'My search term',
          tags: %w[beginner beverages],
          type: SearchContext::ANY,
          options: { team: User.new }
        )
      ).to be_valid
    end

    it 'trows error when creating a USER_ASSIGN search context without a User value' do
      expect do
        SearchContext.new(
          context: SearchContext::USER_ASSIGN,
          term: 'My search term',
          tags: %w[beginner beverages],
          type: SearchContext::ANY
        )
      end.to raise_error(Errors::IllegalSearchContext)
    end
  end

  describe 'Incorrect search context' do
    it 'trows error when creating incorrect search context incorrectly' do
      expect do
        SearchContext.new(
          context: :random,
          term: 'My search term',
          tags: %w[beginner beverages],
          type: SearchContext::ANY
        )
      end.to raise_error(Errors::IllegalSearchContext)
    end

    it 'trows error when creating search context with incorrect type' do
      expect do
        SearchContext.new(
          context: SearchContext::HOME_PAGE,
          term: 'My search term',
          tags: %w[beginner beverages],
          type: :random
        )
      end.to raise_error(Errors::IllegalSearchContext)
    end
  end

  describe 'Sanitize the tags and term' do
    it 'sanitizes the tags' do
      ctx = SearchContext.new(
        context: SearchContext::HOME_PAGE,
        term: 'My search term',
        tags: [nil, '', '  tag '],
        type: SearchContext::ANY
      )

      expect(ctx.tags).to eq(['tag'])
    end

    it 'sanitizes the term' do
      ctx = SearchContext.new(
        context: SearchContext::HOME_PAGE,
        term: ' My search term ',
        tags: [],
        type: SearchContext::ANY
      )

      expect(ctx.term).to eq('My search term')
    end

    it 'sanitizes when the term is nil' do
      ctx = SearchContext.new(
        context: SearchContext::HOME_PAGE,
        term: nil,
        tags: [],
        type: SearchContext::ANY
      )

      expect(ctx.term).to eq('')
    end

    it 'sanitizes when the tags is nil' do
      ctx = SearchContext.new(
        context: SearchContext::HOME_PAGE,
        term: nil,
        tags: nil,
        type: SearchContext::ANY
      )

      expect(ctx.tags).to eq([])
    end
  end
end
