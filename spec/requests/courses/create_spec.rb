# frozen_string_literal: true

RSpec.describe 'Request spec for POST /course' do
  describe 'Creating course by non admin' do
    %i[owner manager learner].each do |role|
      before do
        user = create :user, role
        sign_in user
      end

      it "Fails when #{role} user tries to create a course" do
        params = {
          course: {
            title: Faker::Lorem.sentence(word_count: 5),
            banner: image_file,
            description: Faker::Lorem.paragraph_by_chars(number: 141)
          }
        }

        expect do
          post('/courses', params:)
        end.not_to(change(Course, :count))
        expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
        expect(response.status).to be(302)
      end
    end
  end

  describe 'Create a new course by admin' do
    before do
      admin = create :user, :admin
      sign_in admin
      @category_tag = create :tag
      @level_tag = create :tag, tag_type: :level
    end

    it 'fails when the title is blank' do
      params = {
        course: {
          title: '',
          banner: image_file,
          description: Faker::Lorem.paragraph_by_chars(number: 141)
        }
      }

      expect do
        post('/courses', params:)
      end.not_to(change(Course, :count))

      expect(response.status).to be(422)
    end

    it 'fails when the banner is very large' do
      params = {
        course: {
          title: Faker::Lorem.sentence(word_count: 5),
          banner: big_image_file,
          description: Faker::Lorem.paragraph_by_chars(number: 141)
        }
      }

      expect do
        post('/courses', params:)
      end.not_to(change(Course, :count))
      expect(response.status).to be(422)
    end

    it 'fails when the description is less than 140 chars' do
      params = {
        course: {
          title: Faker::Lorem.sentence(word_count: 5),
          banner: big_image_file,
          description: Faker::Lorem.paragraph_by_chars(number: 120)
        }
      }

      expect do
        post('/courses', params:)
      end.not_to(change(Course, :count))

      expect(response.status).to be(422)
    end

    it 'Allows admin to create a course' do
      params = {
        course: {
          title: Faker::Lorem.sentence(word_count: 5),
          banner: image_file,
          description: Faker::Lorem.paragraph_by_chars(number: 141),
          category_id: @category_tag.id,
          level_id: @level_tag.id
        }
      }

      expect do
        post('/courses', params:)
      end.to change(Course, :count).by(1)

      expect(response.status).to be(302) # redirect to course details page
      course = Course.last
      expect(course.tags.pluck(:id)).to eq([@category_tag.id, @level_tag.id])
    end
  end
end
