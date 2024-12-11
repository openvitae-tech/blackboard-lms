import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["deactivateMenu"];

  toggleDropdown() {
    this.deactivateMenuTarget.classList.toggle("hidden");
  }
}
