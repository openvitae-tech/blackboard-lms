import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["deactivateMenu","activateConfirmation","deactivateConfirmation"];

  toggleDropdown() {
    this.deactivateMenuTarget.classList.toggle("hidden");
  }
  showConfirmation() {
    const isActivate = this.deactivateMenuTarget.getAttribute("data-activate") === "true";
    isActivate 
        ? this.activateConfirmationTarget.classList.remove("hidden")
        : this.deactivateConfirmationTarget.classList.remove("hidden");
    this.deactivateMenuTarget.classList.add("hidden");
}
 
}
