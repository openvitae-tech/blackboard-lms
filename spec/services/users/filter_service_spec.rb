# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::FilterService do
  describe 'with search term' do
    before(:all) do
      @team = create :team
      @learning_partner = @team.learning_partner
      @team2 = create :team, learning_partner: @learning_partner

      @user1 = create :user, :learner, name: 'Paul Sojan', learning_partner: @learning_partner, team: @team
      @user2 = create :user, :learner, name: 'Deepak Kumar', learning_partner: @learning_partner, team: @team
      @user3 = create :user, :learner, name: 'Paul John', learning_partner: @learning_partner, team: @team
      @user4 = create :user, :learner, name: 'Paul Graham', learning_partner: @learning_partner, team: @team2
      @user5 = create :user, :learner, name: 'Sadrishya', learning_partner: @learning_partner, team: @team,
                                       state: User::INACTIVE
    end

    it 'returns active users by matching name' do
      users = Users::FilterService.new(@team, term: 'Paul').filter
      expect(users).to eq([@user1, @user3])
    end

    it 'returns all active users of the team when the term is blank' do
      users = Users::FilterService.new(@team).filter
      expect(users).to eq([@user1, @user2, @user3])
    end

    it 'returns deactivated users with matching term if all_members flag is provided' do
      users = Users::FilterService.new(@team, term: 'Sad', all_members: true).filter
      expect(users).to eq([@user5])
    end

    it 'returns users from matching team' do
      users = Users::FilterService.new(@team2, term: 'Paul').filter
      expect(users).to eq([@user4])
    end
  end
end
