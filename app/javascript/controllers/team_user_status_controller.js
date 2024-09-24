import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["deActivateMenu","activateConfirmation","deactivateConfirmation"];

  toggleDropdown() {
    this.deActivateMenuTarget.classList.toggle("hidden");
  }
  showConfirmation() {
    this.deActivateMenuTarget.textContent.trim() === "Activate" 
        ? this.activateConfirmationTarget.classList.remove("hidden")
        : this.deactivateConfirmationTarget.classList.remove("hidden");


    this.deActivateMenuTarget.classList.add("hidden");
  }

 
}
