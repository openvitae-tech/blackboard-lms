# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /course/:id/enroll' do
  describe 'Enroll course by non admin user' do
    %i[owner manager learner].each do |role|
      before(:each) do
        @team = create :team
        @user = create :user, role, team: @team, learning_partner: @team.learning_partner
        sign_in @user
      end

      subject { course_with_associations }
      let(:user) { @user }

      it "Enroll a #{role} into a course" do
        put("/courses/#{subject.id}/enroll")
        expect(response.status).to be(302)
        expect(flash[:notice]).to eq(I18n.t('course.enrolled'))
        expect(user.enrolled_for_course?(subject)).to be_truthy
      end

      it "Fails if #{role} is already enrolled" do
        subject.enroll!(user)
        put("/courses/#{subject.id}/enroll")
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      end
    end
  end

  describe 'Enroll a course by admin' do
    before(:each) do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    subject { @course }

    it 'fails because admins are not allowed to enroll' do
      put("/courses/#{subject.id}/enroll")
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
