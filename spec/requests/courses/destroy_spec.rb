# frozen_string_literal: true

RSpec.describe 'Request spec for DELETE /courses/:id' do
  describe 'delete a course by non admin' do
    %i[owner manager learner].each do |role|
      subject { @course }

      before do
        user = create :user, role
        sign_in user
        @course = course_with_associations
      end

      it "Fails when #{role} user tries to unpublish a course" do
        delete("/courses/#{subject.id}")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  describe 'delete a course by by admin' do
    before do
      admin = create :user, :admin
      sign_in admin
    end

    it 'Success when admin deletes a course' do
      course = course_with_associations

      expect { delete("/courses/#{course.id}") }.to change(Course, :count).by(-1)

      expect(flash[:notice]).to eq(I18n.t('course.deleted'))
    end

    it 'Fails when admin deletes a published course an already unpublished course' do
      course = course_with_associations(published: true)
      delete("/courses/#{course.id}")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Fails when admin deletes an unpublished course having previous enrollments' do
      team = create :team
      user = create :user, :learner, team:, learning_partner: team.learning_partner
      course = course_with_associations(published: true)
      course.enroll!(user)
      delete("/courses/#{course.id}")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
