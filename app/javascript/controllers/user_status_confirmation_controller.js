import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["inactiveUser", "activeUser", "deactivateMenu","activateConfirmation","deactivateConfirmation"];

  confirm(event) {
    const buttonDataAction = event.currentTarget.dataset.actionType;
    if (buttonDataAction === "deactivateYes") {
      this.deactivateConfirmationTarget.classList.add("hidden");
      this.inactiveUserTarget.classList.remove("hidden");
      this.activeUserTarget.classList.add("hidden");
      this.deactivateMenuTarget.children[0].textContent = "Activate";
      this.deactivateMenuTarget.setAttribute("data-activate", "true");

    } else {
      this.activateConfirmationTarget.classList.add("hidden");
      this.activeUserTarget.classList.remove("hidden");
      this.inactiveUserTarget.classList.add("hidden");
      this.deactivateMenuTarget.children[0].textContent = "Deactivate";
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