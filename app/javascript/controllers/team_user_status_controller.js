import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "deactivateMenu",
    "activateConfirmation",
    "deactivateConfirmation",
  ];

  connect() {
    this.element.addEventListener("statusChange", this.updateStatus.bind(this));
  }

  updateStatus(event) {
    const { activate } = event.detail;
    this.deactivateMenuTarget.setAttribute(
      "data-activate",
      activate ? "true" : "false"
    );
  }

  toggleDropdown() {
    this.deactivateMenuTarget.classList.toggle("hidden");
  }
  showConfirmation() {
    console.log(
      "Updated data-activate:",
      this.deactivateMenuTarget.getAttribute("data-activate")
    );

    const isActivate = this.deactivateMenuTarget.getAttribute("data-activate") === "true";
    isActivate
      ? this.activateConfirmationTarget.classList.remove("hidden")
      : this.deactivateConfirmationTarget.classList.remove("hidden");
    this.deactivateMenuTarget.classList.add("hidden");
  }
}
