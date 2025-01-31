import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "inactiveUser",
    "activeUser",
    "moreMenu",
    "deactivateMenu",
    "activateConfirmation",
    "deactivateConfirmation",
  ];

  showConfirmation() {
    const isActivate =
      this.deactivateMenuTarget.getAttribute("data-activate") === "true";
    isActivate
      ? this.activateConfirmationTarget.classList.remove("hidden")
      : this.deactivateConfirmationTarget.classList.remove("hidden");
    this.moreMenuTarget.classList.add("hidden");
  }

  confirm(event) {
    const buttonDataAction = event.currentTarget.dataset.actionType;
    const isActivate = buttonDataAction === "deactivateYes";

    if (isActivate) {
      this.deactivateConfirmationTarget.classList.add("hidden");
      this.inactiveUserTarget.classList.remove("hidden");
      this.activeUserTarget.classList.add("hidden");
      this.deactivateMenuTarget.textContent = "Activate";
      this.deactivateMenuTarget.setAttribute("data-activate", "true");
    } else {
      this.activateConfirmationTarget.classList.add("hidden");
      this.activeUserTarget.classList.remove("hidden");
      this.inactiveUserTarget.classList.add("hidden");
      this.deactivateMenuTarget.textContent = "Deactivate";
      this.deactivateMenuTarget.setAttribute("data-activate", "false");
    }
  }
  cancel(event) {
    const buttonDataAction = event.currentTarget.dataset.actionType;
    buttonDataAction === "deactivateNo"
      ? this.deactivateConfirmationTarget.classList.add("hidden")
      : this.activateConfirmationTarget.classList.add("hidden");
  }
}
