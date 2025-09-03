# frozen_string_literal: true

module ViewComponent
  module MemberListComponent
    def member_list_component(team:, members:, all_members: false, term: '')
      render partial: 'view_components/member_list/member_list', locals: { team:, members:, all_members:, term: }
    end

    def _member_list_member_search_component(team:, all_members:)
      render partial: 'view_components/member_list/member_search', locals: { team:, all_members: }
    end

    def member_list_members_component(team:, members:, all_members: false, term: '')
      render partial: 'view_components/member_list/members', locals: { team:, members:, all_members:, term: }
    end
  end
end
