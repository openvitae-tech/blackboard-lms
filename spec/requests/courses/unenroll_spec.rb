# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /course/:id/unenroll' do
  describe 'Unenroll course by non admin user' do
    %i[owner manager learner].each do |role|
      before(:each) do
        @team = create :team
        @user = create :user, role, team: @team, learning_partner: @team.learning_partner
        @course = course_with_associations
        @course.enroll!(@user)
        sign_in @user
      end

      subject { @course }
      let(:user) { @user }

      it "unenroll a #{role} into a course" do
        put("/courses/#{subject.id}/unenroll")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('course.unenrolled'))
        expect(user.enrolled_for_course?(subject)).to be_falsey
      end

      it "Fails if #{role} is already unenrolled" do
        subject.undo_enroll!(user)
        put("/courses/#{subject.id}/unenroll")
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  describe 'Unenroll by admin' do
    before(:each) do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    subject { @course }

    it 'fails because admins are not allowed to enroll or unenroll' do
      put("/courses/#{subject.id}/unenroll")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
