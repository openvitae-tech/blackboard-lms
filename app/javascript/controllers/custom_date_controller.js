import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "fromDate", "toDate", "continueBtn", "error"]

  connect() {
    const select = this.element.querySelector('select[name="duration"]')
    if (!select) return

    this._durationSelect = select
    this._lastValidDuration = select.value !== "custom" ? select.value : select.options[0]?.value

    // Add a hidden sentinel option so toggling between "custom" and "_custom_"
    // ensures re-selecting "Custom date" always fires the change event
    if (!select.querySelector('option[value="_custom_"]')) {
      const sentinel = document.createElement("option")
      sentinel.value = "_custom_"
      sentinel.textContent = "Custom date"
      sentinel.style.display = "none"
      select.appendChild(sentinel)
    }

    // If the page loaded with custom date active, switch to the sentinel so that
    // the next selection of "Custom date" fires change (value goes _custom_ → custom)
    if (select.value === "custom") {
      select.value = "_custom_"
    }

    // Track value before user opens the dropdown so we know the "previous" state
    this._previousSelectValue = select.value
    this._onDurationSelectMouseDown = () => {
      this._previousSelectValue = this._durationSelect.value
    }
    select.addEventListener("mousedown", this._onDurationSelectMouseDown)

    this._cancelRestoreValue = select.value
  }

  disconnect() {
    if (this._durationSelect && this._onDurationSelectMouseDown) {
      this._durationSelect.removeEventListener("mousedown", this._onDurationSelectMouseDown)
    }
  }

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
  }

  handleDurationChange(event) {
    const value = event.target.value
    if (value === "custom") {
      // If user was already on custom date (_custom_ sentinel), cancel should
      // restore back to custom date display; otherwise restore to last standard option
      const wasOnCustom = this._previousSelectValue === "_custom_"
      this._cancelRestoreValue = wasOnCustom ? "_custom_" : this._lastValidDuration

      // Toggle to sentinel so re-selecting "Custom date" fires change again next time
      event.target.value = "_custom_"
      this._durationSelect = event.target
      this.modalTarget.classList.remove("hidden")
    } else {
      this._lastValidDuration = value
      this._cancelRestoreValue = value
      Turbo.visit(value)
    }
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.clearError()
    // Restore the select to what was shown before the modal was opened
    if (this._durationSelect) {
      this._durationSelect.value = this._cancelRestoreValue
        || this._lastValidDuration
        || this._durationSelect.options[0]?.value
    }
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
