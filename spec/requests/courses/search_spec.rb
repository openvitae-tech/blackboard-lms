# frozen_string_literal: true

RSpec.describe 'Request spec for GET /courses/search' do
  describe 'course search by learner, manager or owner' do
    %i[manager owner].each do |role|
      before do
        @team = create :team
        @user = create :user, role, team: @team
        sign_in @user
        @courses = Array.new(4) { |index| course_with_associations(published: index.even?) }
      end

      let(:courses) { @courses }
      let(:user) { @user }

      it 'Returns matching results when searching with a search term' do
        term = courses[0].title.split[0]
        get("/courses/search?term=#{term}")
        expect(response.status).to render_template(:index)
        expect(assigns[:search_results]).not_to be_empty
        expect(assigns[:search_results]).to include(courses[0])
      end

      it 'return no results when there are no match or matching course is unpublished' do
        term = courses[1].title.split[0]
        get("/courses/search?term=#{term}")
        expect(response.status).to render_template(:index)
        expect(assigns[:search_results]).not_to include(courses[1])
      end
    end
  end

  describe 'search by admin' do
    before do
      admin = create :user, :admin
      sign_in admin
      @courses = Array.new(4) { |index| course_with_associations(published: index.even?) }
    end

    let(:courses) { @courses }

    it 'Returns matching results when searching with a search term even for unpublished courses' do
      term = courses[1].title.split[0]
      get("/courses/search?term=#{term}")
      expect(response.status).to render_template(:index)
      expect(assigns[:search_results]).not_to be_empty
      expect(assigns[:search_results]).to include(courses[1])
    end
  end
end
