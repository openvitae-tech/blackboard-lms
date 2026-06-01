import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["datePicker", "dateSelector"];

  connect() {
    this.boundSetValue = this.handleSetValue.bind(this);
    this.element.addEventListener("date-picker:set-value", this.boundSetValue);
  }

  disconnect() {
    this.element.removeEventListener("date-picker:set-value", this.boundSetValue);
  }

  datePicked(event) {
    const selectedDate = event.target.value;

    if (selectedDate) {
      this.dateSelectorTarget.value = selectedDate;
    }
  }

  openDatePicker() {
    this.datePickerTarget.showPicker();
  }

  handleSetValue(event) {
    this.dateSelectorTarget.value = event.detail.value;
  }
}
