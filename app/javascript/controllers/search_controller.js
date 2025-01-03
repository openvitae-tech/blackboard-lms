import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchInput", "clearButton"];

  connect() {
    this.updateClearButtonVisibility();
  }

  updateClearButtonVisibility() {
    if (this.searchInputTarget.value.trim() !== "") {
      this.clearButtonTarget.classList.remove("hidden");
    } else {
      this.clearButtonTarget.classList.add("hidden");
    }
  }

  clearSearch() {
    this.searchInputTarget.value = "";
    this.updateClearButtonVisibility();
    this.searchInputTarget.focus();
  }
}
