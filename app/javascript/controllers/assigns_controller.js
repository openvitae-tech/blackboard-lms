import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "durationContainer",
        "labelContainer",
        "customLabelContainer",
        "dateSelector"

    ];

    toggle(event) {
        this.dateSelectorTarget.disabled = !this.dateSelectorTarget.disabled;

        if (!this.dateSelectorTarget.disabled) {
            this.durationContainerTarget.classList.remove("hidden");
        } else {
            this.durationContainerTarget.classList.add("hidden");
        }
    }

    durationChanged(event) {
        if (event.target.value === "custom") {
            this.labelContainerTarget.classList.add("hidden");
            this.customLabelContainerTarget.classList.remove("hidden");
        } else {
            this.customLabelContainerTarget.classList.add("hidden");
            this.labelContainerTarget.classList.remove("hidden");
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
}
