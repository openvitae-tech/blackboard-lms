module SearchContextHelper
  extend ActiveSupport::Concern

  private

  def build_search_context(context: nil, resource: nil)
    options = {}

    context = (context || search_params[:context]).to_sym

    case context
    when SearchContext::TEAM_ASSIGN then
      options[:team] = resource || Team.find(search_params[:team_id])
    when SearchContext::USER_ASSIGN then
      options[:user] = resource || Team.find(search_params[:user_id])
    end

    SearchContext.new(
      context: context,
      term: search_params[:term],
      tags: search_params[:tags],
      type: search_params[:type],
      options:
    )
  end

  def search_params
    if params[:search].present?
      params.require(:search).permit(:context, :team_id, :user_id, :term, :type, :page, tags: [])
    else
      params.permit(:context, :team_id, :user_id, :term, :type, :page, tags: [])
    end
  end
end