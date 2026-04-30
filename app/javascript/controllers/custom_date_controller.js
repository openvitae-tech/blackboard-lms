import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "fromDate", "toDate", "continueBtn", "error"]

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.clearError()
  }

  backdropClose(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  validate() {
    const from = this.fromDateTarget.value
    const to = this.toDateTarget.value

    if (!from || !to) {
      this.continueBtnTarget.disabled = true
      this.clearError()
      return
    }

    const fromDate = new Date(from)
    const toDate = new Date(to)

    if (fromDate >= toDate) {
      this.showError("Start date must be before end date.")
      this.continueBtnTarget.disabled = true
      return
    }

    const diffDays = (toDate - fromDate) / (1000 * 60 * 60 * 24)
    if (diffDays > 183) {
      this.showError("Date range cannot exceed 6 months.")
      this.continueBtnTarget.disabled = true
      return
    }

    this.clearError()
    this.continueBtnTarget.disabled = false
  }

  showError(msg) {
    this.errorTarget.textContent = msg
    this.errorTarget.classList.remove("hidden")
  }

  clearError() {
    this.errorTarget.classList.add("hidden")
  }
}
