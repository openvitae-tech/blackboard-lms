# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /courses/:id/publish' do
  describe 'publish a course by non admin' do
    %i[owner manager learner].each do |role|
      before(:each) do
        user = create :user, role
        sign_in user
        @course = course_with_associations
      end

      subject { @course }

      it "Fails when #{role} user tries to publish a course" do
        put("/courses/#{subject.id}/publish")
        expect(response.status).to be(302)
        expect(subject.reload.published?).to be_falsey
      end
    end
  end

  describe 'publish a course by by admin' do
    before(:each) do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    subject { @course }

    it 'Success when admin publishes a course' do
      put("/courses/#{subject.id}/publish")
      expect(response.status).to be(302)
      expect(subject.reload.published?).to be_truthy
    end
  end
end
