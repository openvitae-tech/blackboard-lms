# frozen_string_literal: true

RSpec.describe 'Request spec for GET /courses' do
  let(:category_tags) { create_list(:tag, 3) }
  let(:level_tags) { create_list(:tag, 2, tag_type: :level) }

  before do
    @courses = Array.new(15) { |index| course_with_associations(published: index.even?) }
    @courses[2].update!(tag_ids: [category_tags.first.id, level_tags.first.id])
    @courses[14].update!(tag_ids: [category_tags.second.id, level_tags.last.id])
    @courses[1].update!(tag_ids: [category_tags.last.id, level_tags.last.id])
  end

  describe 'accessing index page by learner' do
    before do
      @team = create :team
      @user = create :user, :learner, team: @team
      sign_in @user
    end

    let(:courses) { @courses }
    let(:user) { @user }

    it 'successfully renders the index page for a learner' do
      get('/courses')
      expect(response.status).to render_template(:index)
    end

    it 'loads home page data for learners' do
      get('/courses')
      expect(assigns(:data)).to include(:programs, :continue, :categories)
    end

    it 'shows enrolled courses in the continue section' do
      [0, 2, 4, 6].each do |index|
        courses[index].enroll!(user)
      end
      get('/courses')
      enrolled_ids = user.courses.pluck(:id).sort
      expect(assigns(:data)[:continue].pluck(:id).sort).to eq(enrolled_ids)
    end
  end

  describe 'accessing index page by manager or owner' do
    %i[manager owner].each do |role|
      before do
        @team = create :team
        @user = create :user, role, team: @team
        sign_in @user
      end

      let(:courses) { @courses }
      let(:user) { @user }

      it "Success when #{role} tries visit index page" do
        get('/courses')
        expect(response.status).to render_template(:index)
      end

      it "loads home page data for #{role}" do
        get('/courses')
        expect(assigns(:data)).to include(:programs, :continue, :categories)
      end
    end
  end

  describe 'accessing index page by admin' do
    before do
      admin = create :user, :admin
      sign_in admin
    end

    let(:courses) { @courses }

    it 'successfully renders the index page for an admin' do
      get('/courses')
      expect(response.status).to render_template(:index)
    end

    it 'shows only the first 12 available courses on the admin dashboard' do
      get('/courses')
      expect(assigns[:courses].pluck(:id).sort)
        .to eq(Course.limit(12).order(created_at: :desc).pluck(:id).sort)
    end

    it 'shows all available courses when type is all' do
      get('/courses', params: { type: 'all' })
      expect(assigns[:courses].pluck(:id).sort)
        .to eq(Course.limit(12).order(created_at: :desc).pluck(:id).sort)
    end

    it 'filters available courses when tags are provided' do
      get courses_path, params: { type: 'all', tags: [level_tags.last.name] }
      expect(assigns[:courses].pluck(:id).sort).to eq([@courses[14].id, @courses[1].id].sort)
    end

    it 'filters available courses by a search term' do
      get courses_path, params: { type: 'all', term: @courses.last.title }
      expect(assigns[:courses].pluck(:id)).to eq([@courses.last.id])
    end

    it 'filters available courses by search term and tags' do
      get courses_path, params: { type: 'all', term: @courses[2].title, tags: [level_tags.first.id] }
      expect(assigns[:courses].pluck(:id)).to eq([@courses[2].id])
    end
  end
end
