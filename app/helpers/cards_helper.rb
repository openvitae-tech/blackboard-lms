# frozen_string_literal: true

module CardsHelper
  MIN_PROGRAM_CARDS = 5

  def program_cards(programs)
    return [] if programs.empty?

    cards = programs.map do |program|
      link_to program_path(program) do
        program_card_component(program:, user: current_user)
      end
    end

    until cards.size >= MIN_PROGRAM_CARDS
      programs.each do |program|
        cards << (link_to program_path(program), class: 'md:hidden' do
          program_card_component(program:, user: current_user)
        end)
      end
    end

    cards
  end

  def course_cards(courses)
    courses ||= []
    course_ids = courses.map(&:id)
    enrollments = current_user.enrollments.where(course_id: course_ids).index_by(&:course_id)

    courses.map do |course|
      link_to course_path(course) do
        course_card_component(course:, enrollment: enrollments[course.id])
      end
    end
  end
end
