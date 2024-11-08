# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /courses/:id/unpublish' do
  describe 'unpublish a course by non admin' do
    %i[owner manager learner].each do |role|
      subject { @course }

      before do
        user = create :user, role
        sign_in user
        @course = course_with_associations
        @course.update(is_published: true)
      end

      it "Fails when #{role} user tries to unpublish a course" do
        put("/courses/#{subject.id}/unpublish")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
        expect(subject.reload).to be_published
      end
    end
  end

  describe 'unpublish a course by by admin' do
    subject { @course }

    before do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
      @course.update(is_published: true)
    end

    it 'Success when admin unpublish a course' do
      put("/courses/#{subject.id}/unpublish")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('course.unpublished'))
      expect(subject.reload).not_to be_published
    end

    it 'Fails when admin unpublishes an already unpublished course' do
      subject.undo_publish!
      put("/courses/#{subject.id}/unpublish")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
