# frozen_string_literal: true

module ViewComponent
  module Card
    module LongProgramCardComponent
      def long_program_card_component(program:, enrolled_program_ids:)
        name = program.name
        courses_count = program.courses.count
        enroll_count = program.users.count
        is_enrolled = enrolled_program_ids.include?(program.id)
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
