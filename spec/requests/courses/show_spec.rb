# frozen_string_literal: true

RSpec.describe 'Request spec for GET /courses/:id' do
  describe 'accessing new course page by non admin' do
    %i[owner manager learner].each do |role|
      before(:each) do
        user = create :user, role
        sign_in user
        @course = course_with_associations
      end

      subject { @course }

      it "Fails when #{role} user tries to access an unpublisehd course" do
        get("/courses/#{subject.id}")
        expect(response.status).to be(302)
      end

      it "Success when #{role} user tries to access an published course" do
        subject.update(is_published: true)
        get("/courses/#{subject.id}")
        expect(response.status).to be(200)
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'access course details by admin' do
    before(:each) do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    subject { @course }

    it 'Success when admin user tries to access an unpublisehd course' do
      get("/courses/#{subject.id}")
      expect(response).to render_template(:show)
    end

    it 'Success when admin user tries to access an published course' do
      subject.update(is_published: true)
      get("/courses/#{subject.id}")
      expect(response).to render_template(:show)
    end
  end
end
