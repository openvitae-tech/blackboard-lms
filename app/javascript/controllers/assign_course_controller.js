import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "card",
    "durationContainer",
    "labelContainer",
    "customLabelContainer",
  ];

  toggle(event) {
    const card = event.target.closest('[data-item="card"]');
    const durationContainer = card.querySelector(
      '[data-container="durationContainer"]'
    );

    if (event.target.checked) {
      durationContainer.classList.remove("hidden");
    } else {
      durationContainer.classList.add("hidden");
      this.hideCustomDate(card);
    }
  }

  durationChanged(event) {
    const card = event.target.closest('[data-item="card"]');
    const labelContainer = card.querySelector(
      '[data-label="labelContainer"]'
    );
    const customLabelContainer = card.querySelector(
      '[data-label="customLabelContainer"]'
    );

    if (event.target.value === "custom") {
      labelContainer.classList.add("hidden");
      customLabelContainer.classList.remove("hidden");
    } else {
      customLabelContainer.classList.add("hidden");
      labelContainer.classList.remove("hidden");
    }
  }

  datePicked(event) {
    const card = event.target.closest('[data-item="card"]');
    const selectedDate = event.target.value;

    if (selectedDate) {
      const option = new Option(selectedDate, selectedDate);
      const durationSelect = card.querySelector(
        '[data-duration="duration"]'
      );
      durationSelect.appendChild(option);
      durationSelect.value = selectedDate;
    }
  }

  hideCustomDate(card) {
    const customLabelContainer = card.querySelector(
      '[data-label="customLabelContainer"]'
    );
    customLabelContainer.classList.add("hidden");
    const durationSelect = card.querySelector(
      '[data-duration="duration"]'
    );
    durationSelect.value = durationSelect.options[0].value;
    this.showLabel(card);

  }

  showLabel(card) {
    const labelContainer = card.querySelector(
      '[data-label="labelContainer"]'
    );
    labelContainer.classList.remove("hidden");
  }
}
