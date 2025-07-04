module SearchContextHelper
  extend ActiveSupport::Concern

  private

  def build_search_context(context: nil)
    options = {}

    context = context || search_params[:context]

    case context
    when 'team_assign' then
      team = Team.find search_params[:team_id]
      options[:team] = team
    when 'user_assign' then
      user = User.find search_params[:user_id]
      options[:user] = user
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
      params.require(:search).permit(:context, :team_id, :user_id, :term, :tags, :type)
    else
      params.permit(:context, :team_id, :user_id, :term, :tags, :type)
    end
  end
end