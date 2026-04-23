import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitButton", "innerButton"]

  toggleSubmit() {
    const anyChecked = this.element.querySelectorAll('input[name="course_ids[]"]:checked').length > 0

    if (anyChecked) {
      this.submitButtonTarget.removeAttribute("disabled")
      this.innerButtonTarget.classList.remove("btn-disabled", "btn-solid-primary-disabled")
      this.innerButtonTarget.classList.add("btn-solid-primary")
    } else {
      this.submitButtonTarget.setAttribute("disabled", "true")
      this.innerButtonTarget.classList.remove("btn-solid-primary")
      this.innerButtonTarget.classList.add("btn-disabled", "btn-solid-primary-disabled")
    }
  }
}
