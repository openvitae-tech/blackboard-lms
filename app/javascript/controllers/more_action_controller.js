import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["moreMenu"];

  toggleDropdown() {
    this.moreMenuTarget.classList.toggle("hidden");
  }
}
