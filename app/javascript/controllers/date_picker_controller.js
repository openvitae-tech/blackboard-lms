import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["datePicker", "dateSelector"];

  datePicked(event) {
    const selectedDate = event.target.value;

    if (selectedDate) {
      this.dateSelectorTarget.value = selectedDate;
    }
  }

  openDatePicker() {
    this.datePickerTarget.showPicker();
  }
}
