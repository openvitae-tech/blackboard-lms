# frozen_string_literal: true

module ViewComponent
  module TableComponent
    def table_cell_name(row_data, avatar: false)
      { partial: 'shared/components/table_cell_name', locals: { row_data:, avatar: } }
    end

    def table_cell_role(row_data)
      { partial: 'shared/components/table_cell_role', locals: { row_data: } }
    end

    def table_actions(row_data, actions = [])
      actions.each do |action|
        action[:data] ||= {}
        action[:data][:turbo_frame] = action[:turbo_frame] if action[:turbo_frame].present?
      end

      { partial: 'shared/components/table_actions', locals: { row_data:, actions: } }
    end
  end
end
