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

    it 'shows only published courses for learners' do
      get('/courses')
      expect(assigns[:available_courses].pluck(:id).sort).to eq(Course.published.pluck(:id).sort)
    end

    it 'shows only 2 enrolled courses on the learner dashboard' do
      [0, 2, 4, 6].each do |index|
        courses[index].enroll!(user)
      end
      get('/courses')
      expect(assigns[:enrolled_courses].pluck(:id).sort).to eq(user.courses.limit(2).pluck(:id).sort)
    end

    it 'lists all enrolled courses when type is enrolled' do
      get courses_path, params: { type: 'enrolled' }

      expect(assigns[:enrolled_courses].pluck(:id).sort).to eq(user.courses.pluck(:id).sort)
    end

    it 'filters enrolled courses when tags are provided' do
      @courses[2].enroll!(user)

      get courses_path, params: { type: 'enrolled', tags: [category_tags.first.name, level_tags.first.name] }
      expect(assigns[:enrolled_courses]).to eq([@courses[2]])
    end

    it 'filters enrolled courses by search term' do
      @courses[4].enroll!(user)

      get courses_path, params: { type: 'enrolled', term: @courses[4].title }
      expect(assigns[:enrolled_courses].pluck(:id)).to eq([@courses[4].id])
    end

    it 'filters enrolled courses by search term and tags' do
      @courses[14].enroll!(user)

      get courses_path, params: { type: 'enrolled', term: @courses[14].title, tags: [category_tags.second.id] }
      expect(assigns[:enrolled_courses].pluck(:id)).to eq([@courses[14].id])
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
    end

    let(:courses) { @courses }

    it 'successfully renders the index page for an admin' do
      get('/courses')
      expect(response.status).to render_template(:index)
    end

    it 'shows only the first 10 available courses on the admin dashboard' do
      get('/courses')
      expect(assigns[:available_courses].pluck(:id).sort).to eq(Course.limit(10).pluck(:id).sort)
    end

    it 'shows all available courses when type is all' do
      get('/courses', params: { type: 'all' })
      expect(assigns[:available_courses].pluck(:id).sort).to eq(Course.limit(12).pluck(:id).sort)
    end

    it 'filters available courses when tags are provided' do
      get courses_path, params: { type: 'all', tags: [level_tags.last.name] }
      expect(assigns[:available_courses].pluck(:id).sort).to eq([@courses[14].id, @courses[1].id].sort)
    end

    it 'filters available courses by a search term' do
      get courses_path, params: { type: 'all', term: @courses.last.title }
      expect(assigns[:available_courses].pluck(:id)).to eq([@courses.last.id])
    end

    it 'filters available courses by search term and tags' do
      get courses_path, params: { type: 'all', term: @courses[2].title, tags: [level_tags.first.id] }
      expect(assigns[:available_courses].pluck(:id)).to eq([@courses[2].id])
    end
  end
end
