import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "durationContainer",
    "customLabelContainer",
    "dateSelector",
    "datePicker"
  ];

  toggle(event) {
    if (this.hasDateSelectorTarget) {
      this.dateSelectorTarget.disabled = !this.dateSelectorTarget.disabled;

      if (!this.dateSelectorTarget.disabled) {
        this.durationContainerTarget.classList.remove("invisible", "opacity-0");
      } else {
        this.durationContainerTarget.classList.add("invisible", "opacity-0");
      }
    }
  }

  datePicked(event) {
    const selectedDate = event.target.value;

    if (selectedDate) {
      const option = new Option(selectedDate, selectedDate);
      this.dateSelectorTarget.appendChild(option);
      this.dateSelectorTarget.value = selectedDate;
    }
  }

  openDatePicker(event) {
    this.datePickerTarget.showPicker();
    this.datePickerTarget.addEventListener("blur", () => {
    });
  }
}
