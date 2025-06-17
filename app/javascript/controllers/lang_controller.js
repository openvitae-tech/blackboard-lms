import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radio", "otherLanguageField", "otherLanguageInput"];

  languageSelected(event) {
    const selectedValue = event.target.value;

    if (selectedValue === "Other") {
      this.otherLanguageFieldTarget.classList.remove("hidden");
      this.otherLanguageInputTarget.required = true;
    } else {
      this.otherLanguageInputTarget.required = false;
      this.otherLanguageFieldTarget.classList.add("hidden");
    }
  }
}
