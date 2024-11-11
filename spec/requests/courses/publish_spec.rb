# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /courses/:id/publish' do
  describe 'publish a course by non admin' do
    %i[owner manager learner].each do |role|
      subject { @course }

      before do
        user = create :user, role
        sign_in user
        @course = course_with_associations
      end

      it "Fails when #{role} user tries to publish a course" do
        put("/courses/#{subject.id}/publish")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
        expect(subject.reload).not_to be_published
      end
    end
  end

  describe 'publish a course by by admin' do
    subject { @course }

    before do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    it 'Success when admin publishes a course' do
      put("/courses/#{subject.id}/publish")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('course.published'))
      expect(subject.reload).to be_published
    end

    it 'Fails when admin publishes an already published course' do
      subject.publish!
      put("/courses/#{subject.id}/publish")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
