# frozen_string_literal: true

RSpec.describe 'Request spec for GET /courses/:id/edit' do
  describe 'accessing edit course page by non admin' do
    %i[owner manager learner].each do |role|
      before(:each) do
        user = create :user, role
        sign_in user
        @course = course_with_associations
      end

      subject { @course }

      it "Fails when #{role} user tries to edit a course" do
        get("/courses/#{subject.id}/edit")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  describe 'access edit course by admin' do
    before(:each) do
      admin = create :user, :admin
      sign_in admin
    end

    subject { course_with_associations }

    it 'renders edit page for course creation' do
      get("/courses/#{subject.id}/edit")
      expect(response.status).to be(200)
      expect(response).to render_template(:edit)
    end
  end
end
