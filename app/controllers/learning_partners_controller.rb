class LearningPartnersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :set_learning_partner, only: %i[ show edit update destroy ]

  # GET /learning_partners or /learning_partners.json
  def index
    @learning_partners = LearningPartner.all
  end

  # GET /learning_partners/1 or /learning_partners/1.json
  def show
  end

  # GET /learning_partners/new
  def new
    @learning_partner = LearningPartner.new
  end

  # GET /learning_partners/1/edit
  def edit
  end

  # POST /learning_partners or /learning_partners.json
  def create
    @learning_partner = LearningPartner.new(learning_partner_params)

    respond_to do |format|
      if @learning_partner.save
        format.html { redirect_to learning_partner_url(@learning_partner), notice: "Learning partner was successfully created." }
        format.json { render :show, status: :created, location: @learning_partner }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @learning_partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /learning_partners/1 or /learning_partners/1.json
  def update
    respond_to do |format|
      if @learning_partner.update(learning_partner_params)
        format.html { redirect_to learning_partner_url(@learning_partner), notice: "Learning partner was successfully updated." }
        format.json { render :show, status: :ok, location: @learning_partner }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @learning_partner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /learning_partners/1 or /learning_partners/1.json
  def destroy
    @learning_partner.destroy!

    respond_to do |format|
      format.html { redirect_to learning_partners_url, notice: "Learning partner was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_learning_partner
      @learning_partner = LearningPartner.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def learning_partner_params
      params.require(:learning_partner).permit(:name, :about)
    end
end
