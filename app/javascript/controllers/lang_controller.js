import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["radio", "otherLanguageField", "otherLanguageInput"];

  connect() {
    this.toggleOtherLanguageField();
  }
  
  languageSelected(event) {
    this.toggleOtherLanguageField(event.target.value);
  }
  
  toggleOtherLanguageField(selectedValue = null) {
    if (!selectedValue) {
      const selected = this.radioTargets.find(radio => radio.checked);
      selectedValue = selected?.value;
    }
  
    if (selectedValue === "Other") {
      this.otherLanguageFieldTarget.classList.remove("hidden");
      this.otherLanguageInputTarget.required = true;
    } else {
      this.otherLanguageInputTarget.required = false;
      this.otherLanguageFieldTarget.classList.add("hidden");
    }
  }
  
}
