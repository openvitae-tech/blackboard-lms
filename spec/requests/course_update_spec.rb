# frozen_string_literal: true

RSpec.describe 'Request spec for PUT /course' do
  describe 'Creating course by non admin' do
    %i[owner manager learner].each do |role|
      before(:each) do
        user = create :user, role
        sign_in user
        @course = course_with_associations
      end

      subject { @course }

      it "Fails when #{role} user tries to update a course" do
        params = {
          course: {
            title: Faker::Lorem.sentence(word_count: 5)
          }
        }

        put("/courses/#{subject.id}", params:)
        expect(response.status).to be(302)
      end
    end
  end

  describe 'Update a course by admin' do
    before(:each) do
      admin = create :user, :admin
      sign_in admin
      @course = course_with_associations
    end

    subject { @course }

    it 'fails when the title is blank' do
      params = {
        course: {
          title: ''
        }
      }

      put("/courses/#{subject.id}", params:)

      expect(response.status).to be(422)
    end

    it 'fails when the banner is very large' do
      params = {
        course: {
          banner: big_image_file
        }
      }

      put("/courses/#{subject.id}", params:)
      expect(response.status).to be(422)
    end

    it 'fails when the description is less than 140 chars' do
      params = {
        course: {
          description: Faker::Lorem.paragraph_by_chars(number: 120)
        }
      }

      put("/courses/#{subject.id}", params:)

      expect(response.status).to be(422)
    end

    it 'Allows admin to update a course' do
      new_title = Faker::Lorem.sentence(word_count: 5)
      params = {
        course: {
          title: new_title
        }
      }

      put("/courses/#{subject.id}", params:)
      expect(subject.reload.title).to eq(new_title)
      expect(response.status).to be(302) # redirect to course details page
    end
  end
end
