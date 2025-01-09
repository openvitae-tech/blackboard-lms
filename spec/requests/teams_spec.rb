# frozen_string_literal: true

RSpec.describe 'Request spec for feature teams' do
  before do
    @parent_team = create :team
    @user = create :user, :manager, team: @parent_team, learning_partner: @parent_team.learning_partner
    sign_in @user
  end

  describe 'GET /teams/new' do
    it 'Allow access new team by manager' do
      get new_team_path(@parent_team)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'Unauthorized when new team is accessed by non-manager' do
      @user.update(role: :learner)

      get new_team_path(@parent_team)
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to('/error_401')
    end
  end

  describe 'GET /teams/:id' do
    before do
      @user_two = create :user, :learner, team: @parent_team, learning_partner: @parent_team.learning_partner
    end

    it 'Allow access team by manager' do
      get team_path(@parent_team)
      expect(assigns(:learning_partner)).to eq(@parent_team.learning_partner)
      expect(assigns(:members).pluck(:id).sort).to eq([@user.id, @user_two.id].sort)
    end

    it 'Unauthorized when team is accessed by non-manager' do
      @user.update(role: :learner)

      get team_path(@parent_team)
      expect(response.status).to be(302)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to('/error_401')
    end
  end

  describe 'POST /teams' do
    before do
      @params = {
        team: {
          name: Faker::Restaurant.name,
          banner: image_file,
          parent_team_id: @parent_team.id,
          department: 'NA'
        }
      }
    end

    it 'Allows manager to create a subteam' do
      expect do
        post teams_path, params: @params
      end.to change(Team, :count).by(1)
      expect(assigns[:team].department).to eq('NA')
    end

    it 'Unauthorized when creating team by non-manager' do
      @user.update(role: :learner)

      expect do
        post teams_path, params: @params
      end.not_to(change(Team, :count))
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to('/error_401')
    end
  end

  describe 'GET /teams/:id/edit' do
    it 'Allow access edit team by manager' do
      get edit_team_path(@parent_team.id)

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end

    it 'Unauthorized when edit team accessed by non-manager' do
      @user.update(role: :learner)

      get edit_team_path(@parent_team.id)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to('/error_401')
    end
  end

  describe 'PUT /teams/:id' do
    before do
      @params = {
        team: {
          name: Faker::Restaurant.name
        }
      }
    end

    it 'Allows manager to update a team' do
      put team_path(@parent_team.id), params: @params
      expect(@parent_team.reload.name).to eq(@params[:team][:name])
    end

    it 'Unauthorized when updating team by non-manager' do
      @user.update(role: :learner)

      put team_path(@parent_team.id), params: @params
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to('/error_401')
    end
  end
end
