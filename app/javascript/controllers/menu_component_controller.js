import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["moreMenu","menuButton"];

  connect() {
    window.addEventListener("click",(e) => {
      if (!this.moreMenuTarget.contains(e.target)) {
        if (!this.isMenuHidden()) {
          this.toggleDropdown(e);
        }
      }
    })
  }

  toggleDropdown(event) {
    event.stopPropagation();
    this.moreMenuTarget.classList.toggle("hidden");
    this.menuButtonTarget.classList.toggle("menu-component-button-active")

  }

  isMenuHidden() {
    return this.moreMenuTarget.classList.contains("hidden");
  }
}
