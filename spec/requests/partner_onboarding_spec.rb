RSpec.describe "LearningPartner" do
  before(:each) do
    admin_user = create :user, :admin
    sign_in admin_user
  end

  it "lists all partners" do
    partners = (1..3).map { |_| create :learning_partner }.sort_by { |r| r.name }
    get "/learning_partners"
    expect(response).to have_http_status(:success)
    expect(response).to render_template(:index)
    expect(assigns(:learning_partners)).to eq(partners)
  end

  describe "onboarding" do
    it "Creates a new partner" do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          about: partner.about
        }
      }
      post "/learning_partners", params: params
      expect(response).to redirect_to(assigns(:learning_partner))
    end

    it "Creates an event onboarding_initiated" do
      partner = build :learning_partner
      params = {
        learning_partner: {
          name: partner.name,
          about: partner.about
        }
      }

      expect do
        post "/learning_partners", params: params
      end.to change { Event.count }.by(1)

      event = Event.last
      expect(event.name).to eq("onboarding_initiated")
    end
  end
end
