# frozen_string_literal: true

module ViewComponent
  module Card
    module LongProgramCardComponent
      def long_program_card_component(program:, user:)
        name = program.name
        courses_count = program.courses.count
        enroll_count = program.users.count
        is_enrolled = program.program_users.exists?(user:)
        render partial: 'view_components/cards/long_program_card_component', locals: {
          name:,
          courses_count:,
          enroll_count:,
          is_enrolled:
        }
      end
    end
  end
end
