import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "card",
    "durationContainer",
    "labelContainer",
    "customLabelContainer",
  ];

  toggle(event) {
    const card = event.target.closest('[data-assign-course-target="card"]');
    const durationContainer = card.querySelector(
      '[data-assign-course-target="durationContainer"]'
    );

    if (event.target.checked) {
      durationContainer.classList.remove("hidden");
    } else {
      durationContainer.classList.add("hidden");
      this.hideCustomDate(card);
      this.showLabel(card);
    }
  }

  durationChanged(event) {
    const card = event.target.closest('[data-assign-course-target="card"]');
    const labelContainer = card.querySelector(
      '[data-assign-course-target="labelContainer"]'
    );
    const customLabelContainer = card.querySelector(
      '[data-assign-course-target="customLabelContainer"]'
    );

    if (event.target.value === "custom") {
      labelContainer.classList.add("hidden");
      customLabelContainer.classList.remove("hidden");
    } else {
      this.hideCustomDate(card);
      labelContainer.classList.remove("hidden");
    }
  }

  datePicked(event) {
    const card = event.target.closest('[data-assign-course-target="card"]');
    const selectedDate = event.target.value;

    if (selectedDate) {
      const option = new Option(selectedDate, selectedDate);
      const durationSelect = card.querySelector(
        '[data-action="change->assign-course#durationChanged"]'
      );
      durationSelect.appendChild(option);
      durationSelect.value = selectedDate;
    }
  }

  hideCustomDate(card) {
    const customLabelContainer = card.querySelector(
      '[data-assign-course-target="customLabelContainer"]'
    );
    customLabelContainer.classList.add("hidden");
    const durationSelect = card.querySelector(
      '[data-action="change->assign-course#durationChanged"]'
    );
    durationSelect.value = durationSelect.options[0].value;
  }

  showLabel(card) {
    const labelContainer = card.querySelector(
      '[data-assign-course-target="labelContainer"]'
    );
    labelContainer.classList.remove("hidden");
  }
}
