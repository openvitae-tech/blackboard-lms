import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["inactiveUser", "activeUser", "deActivateMenu","activateConfirmation","deactivateConfirmation"];

  confirm(event) {
    const buttonId = event.currentTarget.id;
    if (buttonId === "de-activate-yes") {
      this.deactivateConfirmationTarget.classList.add("hidden");
      this.inactiveUserTarget.classList.remove("hidden");
      this.activeUserTarget.classList.add("hidden");
      this.deActivateMenuTarget.children[0].textContent = "Activate";
    } else {
      this.activateConfirmationTarget.classList.add("hidden");
      this.activeUserTarget.classList.remove("hidden");
      this.inactiveUserTarget.classList.add("hidden");
      this.deActivateMenuTarget.children[0].textContent = "Deactivate";
    }
  }
  cancel(event) {
    const buttonId = event.currentTarget.id;
    if (buttonId === "de-activate-no" || buttonId==="cancel-btn-deactive") {
      this.deactivateConfirmationTarget.classList.add("hidden");
    } else {
      this.activateConfirmationTarget.classList.add("hidden");
    }
  }

}