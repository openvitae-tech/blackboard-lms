# frozen_string_literal: true

module CardsHelper
  MIN_PROGRAM_CARDS = 5

  def program_cards(programs)
    return [] if programs.empty?

    enrolled_program_ids = current_user.program_ids.to_set

    cards = programs.map do |program|
      link_to program_path(program, mode: 'learner') do
        program_card_component(program:, enrolled_program_ids:)
      end
    end

    until cards.size >= MIN_PROGRAM_CARDS
      programs.each do |program|
        cards << (link_to program_path(program, mode: 'learner'), class: 'md:hidden' do
          program_card_component(program:, enrolled_program_ids:)
        end)
      end
    end

    cards
  end

  def course_cards(courses)
    courses ||= []
    course_ids = courses.map(&:id)
    enrollments = current_user.enrollments.where(course_id: course_ids)
                              .preload(course: :course_modules)
                              .index_by(&:course_id)

    courses.map do |course|
      link_to course_path(course) do
        course_card_component(course:, enrollment: enrollments[course.id])
      end
    end
  end

  def certificate_cards(course_certificates)
    return [] if course_certificates.empty?

    course_certificates.map do |certificate|
      certificate_card_component(certificate:)
    end
  end
end
