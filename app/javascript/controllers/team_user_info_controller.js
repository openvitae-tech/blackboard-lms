import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["deActive", "active", "deActiveMenu"];

  toggleDropdown() {
    const menu = this.element.querySelector(".deactivate-menu");
    menu.classList.toggle("hidden");
  }
  showConfirmation() {
    if (this.deActiveMenuTarget.textContent.trim() === "Active") {
      const confirmationModal = this.element.querySelector(
        ".activate-confirmation"
      );
      confirmationModal.classList.remove("hidden");
    } else {
      const confirmationModal = this.element.querySelector(
        ".deactivate-confirmation"
      );
      confirmationModal.classList.remove("hidden");
    }

    const menu = this.element.querySelector(".deactivate-menu");
    menu.classList.add("hidden");
  }

  confirm(event) {
    const buttonId = event.currentTarget.id;
    if (buttonId === "de-activate-yes") {
      console.log("deactivate");
      const confirmationModal = this.element.querySelector(
        ".deactivate-confirmation"
      );
      confirmationModal.classList.add("hidden");
      this.deActiveTarget.classList.remove("hidden");
      this.activeTarget.classList.add("hidden");
      this.deActiveMenuTarget.textContent = "Active";
    } else {
      console.log("activate");
      const confirmationModal = this.element.querySelector(
        ".activate-confirmation"
      );
      confirmationModal.classList.add("hidden");
      this.activeTarget.classList.remove("hidden");
      this.deActiveTarget.classList.add("hidden");
      this.deActiveMenuTarget.textContent = "Deactive";
    }
  }
  cancel(event) {
    const buttonId = event.currentTarget.id;
    if (buttonId === "de-activate-no") {
      console.log("deactivate");
      const confirmationModal = this.element.querySelector(
        ".deactivate-confirmation"
      );
      confirmationModal.classList.add("hidden");
    } else {
      console.log("activate");
      const confirmationModal = this.element.querySelector(
        ".activate-confirmation"
      );
      confirmationModal.classList.add("hidden");
    }
  }
}
