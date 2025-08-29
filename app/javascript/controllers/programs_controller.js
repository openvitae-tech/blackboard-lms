import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "courseCheckbox",
    "deleteButton",
    "coursesCount",
    "selectedCoursesCount",
  ];

  bulkDelete(event) {
    const url = event.currentTarget.dataset.url;
    const selectedIds = this.courseCheckboxTargets
      .filter((cb) => cb.checked)
      .map((cb) => cb.value);

    if (selectedIds.length === 0) return;

    const bulkUrl = new URL(url, window.location.origin);
    selectedIds.forEach((id) =>
      bulkUrl.searchParams.append("course_ids[]", id)
    );

    Turbo.visit(bulkUrl, { frame: "modal" });
  }

  toggleDeleteButton() {
    const checkedCheckboxes = this.courseCheckboxTargets.filter(
      (cb) => cb.checked
    );
    const anyChecked = checkedCheckboxes.length > 0;

    this.deleteButtonTarget.classList.toggle("hidden", !anyChecked);
    this.coursesCountTarget.classList.toggle("hidden", anyChecked);
    this.selectedCoursesCountTarget.textContent = checkedCheckboxes.length;
  }
}
