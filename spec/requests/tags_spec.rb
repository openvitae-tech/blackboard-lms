# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Tags', type: :request do
  let(:user) { create(:user, :admin) }
  let(:learner) { create(:user, :learner) }

  before do
    sign_in user
    @tags = create_list(:tag, 3)
  end

  describe 'GET /tags' do
    it 'Allow listing tags by admin' do
      get tags_path
      expect(response.status).to be(200)
      tags = Tag.pluck(:id).sort
      expect(assigns(:tags).pluck(:id).sort).to eq(tags)
    end

    it 'Unauthorized when tags is accessed by non-admin' do
      sign_in learner

      get tags_path
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /tags/new' do
    it 'Renders the new template for admin' do
      get new_tag_path

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'Returns unauthorized for non-admin' do
      sign_in learner

      get new_tag_path
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'POST /tags' do
    it 'Allow creating tags by admin' do
      expect do
        post tags_path, params: tag_params
      end.to change(Tag, :count).by(1)
    end

    it 'Does not allow creating tag by non-admin' do
      sign_in learner

      expect do
        post tags_path, params: tag_params
      end.not_to(change(Tag, :count))
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Create tag failure' do
      post tags_path, params: { tag: { name: nil } }

      expect(response.status).to eq(422)
    end
  end

  describe 'PUT /tags/:id' do
    before do
      @tag = Tag.first
    end

    it 'Allow updating tag by admin' do
      put tag_path(@tag.id), params: tag_params
      expect(@tag.reload.name).to eq(tag_params[:tag][:name])
    end

    it 'Does not allow updating tag by non-admin' do
      sign_in learner

      put tag_path(@tag.id), params: tag_params
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Update tag failure' do
      put tag_path(@tag.id), params: { tag: { name: nil } }

      expect(response.status).to eq(422)
    end
  end

  describe 'GET /tags/:id/edit' do
    before do
      @tag = Tag.first
    end

    it 'Allow access edit tag by admin' do
      get edit_tag_path(@tag.id)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end

    it 'Unauthorized when edit tag accessed by non-admin' do
      sign_in learner

      get edit_tag_path(@tag.id)

      expect(response).to have_http_status(:found)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'DELETE /tags/:id' do
    before do
      @tag = Tag.first
    end

    it 'Allow deleting tag by admin' do
      expect do
        delete tag_path(@tag.id)
      end.to change(Tag, :count).by(-1)
      expect(flash[:success]).to eq(I18n.t('resource.deleted', resource_name: 'Tag'))
    end

    it 'returns to previous page upon deleting the last item in the current page' do
      create_list(:tag, 7)
      tag = Tag.last

      expect do
        delete tag_path(tag), params: { page: 2 }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      end.to change(Tag, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(flash[:success]).to eq(I18n.t('resource.deleted', resource_name: 'Tag'))
      expect(response.body)
        .to include('<turbo-stream url="/tags?page=1" action="redirect_to"><template></template></turbo-stream>')
    end

    it 'Does not allow deleting tag by non-admin' do
      sign_in learner

      expect do
        delete tag_path(@tag.id)
      end.not_to change(Tag, :count)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'Destroy tag failure' do
      invalid_id = 123
      delete tag_path(invalid_id)

      expect(response).to have_http_status(:not_found)
    end
  end

  private

  def tag_params
    {
      tag: {
        name: 'test tag'
      }
    }
  end
end
