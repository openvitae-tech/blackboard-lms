module SearchContextHelper
  extend ActiveSupport::Concern

  private

  def build_search_context
    options = {}

    case params[:context]
    when 'team_assign' then
      team = Team.find params[:team_id]
      options[:team] = team
    when 'user_assign' then
      user = User.find params[:user_id]
      options[:user] = user
    end

    SearchContext.new(
      context: params[:context],
      term: params[:term],
      tags: params[:tags],
      options:
    )
  end

  def search_params
    params.require(:search).permit(:context, :team_id, :user_id, :term, :tags)
  end
end