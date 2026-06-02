import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "durationContainer",
        "customLabelContainer",
        "dateSelector",
        "datePicker"
    ];

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
