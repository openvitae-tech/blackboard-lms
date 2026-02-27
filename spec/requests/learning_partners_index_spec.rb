# frozen_string_literal: true

RSpec.describe 'Request spec for LearningPartnersController' do
  describe 'GET /learning_partners' do
    before do
      sign_in create(:user, :admin)
    end

    context 'without a query param' do
      it 'returns all learning partners ordered by name' do
        partner_b = create(:learning_partner, name: 'Beta Academy')
        partner_a = create(:learning_partner, name: 'Alpha Institute')

        get learning_partners_path

        expect(response).to have_http_status(:ok)
        expect(assigns(:learning_partners).map(&:id)).to eq([partner_a.id, partner_b.id])
      end
    end

    context 'with a query param' do
      before do
        create(:learning_partner, name: 'Alpha Institute')
        create(:learning_partner, name: 'Alpha Academy')
        create(:learning_partner, name: 'Beta Corp')
      end

      it 'returns partners whose name starts with the query' do
        get learning_partners_path, params: { query: 'Alpha' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:learning_partners).map(&:name)).to contain_exactly('Alpha Institute', 'Alpha Academy')
      end

      it 'is case insensitive' do
        get learning_partners_path, params: { query: 'alpha' }

        expect(assigns(:learning_partners).map(&:name)).to contain_exactly('Alpha Institute', 'Alpha Academy')
      end

      it 'does not return partners whose name only contains the query as a suffix' do
        get learning_partners_path, params: { query: 'Corp' }

        expect(assigns(:learning_partners)).to be_empty
      end

      it 'returns no results when query matches nothing' do
        get learning_partners_path, params: { query: 'Zzz' }

        expect(assigns(:learning_partners)).to be_empty
      end

      it 'returns all partners when query is blank' do
        get learning_partners_path, params: { query: '' }

        expect(assigns(:learning_partners).count).to eq(3)
      end
    end
  end
end
