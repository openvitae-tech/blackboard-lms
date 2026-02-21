# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::CoursesController', type: :request do
  let(:auth_token) { Rails.application.credentials[:api_token] }
  let(:course) { create :course, :published }

  describe 'GET /api/v1/courses/:id' do
    context 'when auth_token is missing' do
      it 'returns unauthorized' do
        get "/api/v1/courses/#{course.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when auth_token is invalid' do
      it 'returns unauthorized' do
        get "/api/v1/courses/#{course.id}", params: { auth_token: 'invalid_token' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when course does not exist' do
      it 'returns not found' do
        get '/api/v1/courses/0', params: { auth_token: }
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to eq({ 'error' => 'Course not found' })
      end
    end

    context 'when course exists' do
      it 'returns 200 ok' do
        get "/api/v1/courses/#{course.id}", params: { auth_token: }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the course as json' do
        get "/api/v1/courses/#{course.id}", params: { auth_token: }
        course_data = response.parsed_body
        expect(course_data['id']).to eq(course.id)
        expect(course_data['title']).to eq(course.title)
        expect(course_data['is_published']).to be(true)
      end

      it 'returns all expected course attributes' do
        get "/api/v1/courses/#{course.id}", params: { auth_token: }
        course_data = response.parsed_body
        expected_keys = %w[banner categories course_modules_count created_at description duration
                           enrollments_count id is_published levels modules rating
                           team_enrollments_count title updated_at visibility]
        expect(course_data.keys.sort).to eq(expected_keys)
      end
    end
  end
end
