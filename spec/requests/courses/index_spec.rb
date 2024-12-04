# frozen_string_literal: true

RSpec.describe 'Request spec for GET /courses' do
  describe 'accessing index page by learner' do
    before do
      @team = create :team
      @user = create :user, :learner, team: @team
      sign_in @user
      @courses = Array.new(4) { |index| course_with_associations(published: index.even?) }
    end

    let(:courses) { @courses }
    let(:user) { @user }

    it 'Success when learner tries visit index page' do
      get('/courses')
      expect(response.status).to render_template(:index)
    end

    it 'for learners results contains only published courses' do
      get('/courses')
      expect(assigns[:available_courses]).to be_all(&:published?)
    end

    it 'for learners results contains any enrolled courses' do
      courses[0].enroll!(user)
      get('/courses')
      expect(assigns[:enrolled_courses]).to eq([courses[0]])
    end
  end

  describe 'accessing index page by manager or owner' do
    %i[manager owner].each do |role|
      before do
        @team = create :team
        @user = create :user, role, team: @team
        sign_in @user
        @courses = Array.new(4) { |index| course_with_associations(published: index.even?) }
      end

      let(:courses) { @courses }
      let(:user) { @user }

      it "Success when #{role} tries visit index page" do
        get('/courses')
        expect(response.status).to render_template(:index)
      end

      it "for #{role} results contains only published courses" do
        get('/courses')
        expect(assigns[:available_courses]).to be_all(&:published?)
      end
    end
  end

  describe 'accessing index page by admin' do
    before do
      admin = create :user, :admin
      sign_in admin
      @courses = Array.new(4) { |index| course_with_associations(published: index.even?) }
    end

    let(:courses) { @courses }

    it 'Success when admin tries visit index page' do
      get('/courses')
      expect(response.status).to render_template(:index)
    end

    it 'for admin results contains all available courses' do
      get('/courses')
      expect(assigns[:available_courses].pluck(:id).sort).to eq(Course.limit(10).pluck(:id).sort)
    end
  end
end
