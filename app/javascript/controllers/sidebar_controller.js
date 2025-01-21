import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sidebar", "overlay", "sidebarCheckbox"];

  connect() {
    this.handleOutsideClick = this.handleOutsideClick.bind(this);
    document.addEventListener("click", this.handleOutsideClick);
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick);
  }

  toggleSidebar() {
    this.sidebarCheckboxTarget.checked = !this.sidebarCheckboxTarget.checked;
  }

  closeSidebar() {
    this.sidebarCheckboxTarget.checked = false;
  }

  handleOutsideClick(event) {
    if (!this.sidebarTarget.contains(event.target) && !this.overlayTarget.contains(event.target) && !this.sidebarCheckboxTarget.contains(event.target)) {
      this.closeSidebar();
    }
  }
}
