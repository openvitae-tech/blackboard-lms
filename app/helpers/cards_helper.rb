# frozen_string_literal: true

module CardsHelper
  MIN_PROGRAM_CARDS = 5

  def program_cards(programs)
    return [] if programs.empty?

    enrolled_program_ids = current_user.program_ids.to_set

    cards = programs.map do |program|
      link_to program_path(program, mode: Program::LEARNER_MODE) do
        program_card_component(program:, enrolled_program_ids:)
      end
    end

    until cards.size >= MIN_PROGRAM_CARDS
      programs.each do |program|
        cards << (link_to program_path(program, mode: Program::LEARNER_MODE), class: 'md:hidden' do
          program_card_component(program:, enrolled_program_ids:)
        end)
      end
    end

    cards
  end

  def course_cards(courses)
    courses ||= []
    enrollments = current_user.enrollments.indexed_by_course(courses)
    courses.map do |course|
      link_to course_path(course) do
        build_course_card(course, enrollments[course.id])
      end
    end
  end

  def certificate_cards(course_certificates)
    return [] if course_certificates.empty?

    course_certificates.map do |certificate|
      certificate_card_component(certificate:)
    end
  end

  def build_course_card(course, enrollment)
    course_card_component(**course_card_params(course, enrollment))
  end

  def build_long_course_card(course, enrollment)
    long_course_card_component(**course_card_params(course, enrollment))
  end

  def course_card_params(course, enrollment)
    level_tag = course.tags.find { |t| t.tag_type == 'level' }
    {
      title: course.title,
      banner_url: course_banner(course, :horizontal),
      duration: course_duration(course),
      modules_count: modules_count(course),
      enroll_count: enroll_count(course),
      categories: course.tags.select { |t| t.tag_type == 'category' }.map(&:name),
      badge: level_tag && { label: level_tag.name },
      rating: course.rating,
      progress: enrollment&.progress
    }
  end
end
