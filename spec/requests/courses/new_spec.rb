# frozen_string_literal: true

RSpec.describe 'Request spec for GET /courses/new' do
  describe 'accessing new course page by non admin' do
    %i[owner manager learner].each do |role|
      before do
        user = create :user, role
        sign_in user
      end

      it "Fails when #{role} user tries to create a course" do
        get('/courses/new')
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  describe 'access new course by admin' do
    before do
      admin = create :user, :admin
      sign_in admin
    end

    it 'renders new page for course creation' do
      get('/courses/new')
      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end
  end
end
