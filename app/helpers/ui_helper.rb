# frozen_string_literal: true

module UiHelper
  def arrange_tags(left_tag, right_tag, position)
    ordered = position == 'left' ? [left_tag, right_tag] : [right_tag, left_tag]
    safe_join(ordered.compact)
  end

  include ViewComponent::TypographyComponent
  include ViewComponent::IconComponent
  include ViewComponent::ButtonComponent
  include ViewComponent::InputComponent
  include ViewComponent::TableComponent
  include ViewComponent::ModalComponent
  include ViewComponent::CourseCardComponent
  include ViewComponent::LongCourseCardComponent
  include ViewComponent::CourseCarousalComponent
  include ViewComponent::CourseSelectComponent
  include ViewComponent::MemberListComponent
  include ViewComponent::NotificationBarComponent
  include ViewComponent::PaginatorComponent
  include ViewComponent::InputTextareaComponent
  include ViewComponent::DocSectionComponent
  include ViewComponent::BreadcrumbsComponent
  include ViewComponent::MenuComponent
  include ViewComponent::ModalBoxComponent
  include ViewComponent::ChipComponent
  include ViewComponent::ProgressComponent
  include ViewComponent::ProfileIconComponent
  include ViewComponent::AccordionComponent
end
