# frozen_string_literal: true

module ViewComponent
  module Card
    module ProgramCardComponent
      def program_card_component(program:, user:)
        name = program.name
        courses_count = program.courses.count
        is_enrolled = program.program_users.exists?(user:)
        render partial: 'view_components/cards/program_card_component', locals: {
          name:,
          courses_count:,
          is_enrolled:
        }
      end
    end
  end
end
