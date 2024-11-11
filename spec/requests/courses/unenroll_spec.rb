# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /course/:id/unenroll' do
  describe 'Unenroll course by non admin user' do
    %i[owner manager learner].each do |role|
      subject { @course }

      before do
        @team = create :team
        @user = create :user, role, team: @team, learning_partner: @team.learning_partner
        @course = course_with_associations
        @course.enroll!(@user)
        sign_in @user
      end

      let(:user) { @user }

      it "unenroll a #{role} into a course" do
        put("/courses/#{subject.id}/unenroll")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('course.unenrolled'))
        expect(user).not_to be_enrolled_for_course(subject)
      end

      it "Fails if #{role} is already unenrolled" do
        subject.undo_enroll!(user)
        put("/courses/#{subject.id}/unenroll")
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  describe 'Unenroll by admin' do
    subject { @course }

    before do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    it 'fails because admins are not allowed to enroll or unenroll' do
      put("/courses/#{subject.id}/unenroll")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
