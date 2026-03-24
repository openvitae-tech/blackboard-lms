# frozen_string_literal: true

module CardsHelper
  MIN_PROGRAM_CARDS = 5

  def program_cards(programs)
    return [] if programs.empty?

    enrolled_program_ids = current_user.program_ids.to_set

    cards = programs.map do |program|
      link_to program_path(program) do
        program_card_component(program:, enrolled_program_ids:)
      end
    end

    until cards.size >= MIN_PROGRAM_CARDS
      programs.each do |program|
        cards << (link_to program_path(program), class: 'md:hidden' do
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

  MIN_CERTIFICATE_CARDS = 5

  def certificate_cards(course_certificates)
    return [] if course_certificates.empty?

    course_certificates = course_certificates.with_attached_file

    cards = build_certificate_cards(course_certificates)
    pad_certificate_cards(cards, course_certificates)
    cards
  end

  private

  def build_certificate_cards(course_certificates)
    course_certificates.map do |certificate|
      certificate_card_component(certificate:)
    end
  end

  def pad_certificate_cards(cards, course_certificates)
    until cards.size >= MIN_CERTIFICATE_CARDS
      added = false
      course_certificates.each do |certificate|
        cards << content_tag(:div, certificate_card_component(certificate:), class: 'md:hidden pl-2')
        added = true
      end
      break unless added
    end
  end
end
