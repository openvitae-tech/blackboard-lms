import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    static targets = ["langOption", "radioDots", "otherLanguageField", "otherLanguageInput"];


    languageSelected(event) {
        const selectedLang = event.currentTarget;

        this.langOptionTargets.forEach((target) => {
            // mark the hidden checkbox as checked
            target.checked = target.dataset.index === selectedLang.dataset.index;

            // show the text field if the checked item is 'Other'
            if (target.checked && (target.dataset.index === "radio-other")) {
                this.otherLanguageFieldTarget.classList.remove("hidden");
            } else {
                this.otherLanguageFieldTarget.classList.add("hidden");
            }
        });

        // show the dot for the checked checkbox
        this.radioDotsTargets.forEach((target) => {
            if (target.dataset.index === selectedLang.dataset.index) {
                target.classList.remove("hidden");
            } else {
                target.classList.add("hidden");
            }
        });
    }

    useOtherLanguage(event) {
        const otherLanguageInput = event.currentTarget;
        const otherRadioInput = this.langOptionTargets.filter((target) => target.dataset.index === "radio-other")[0];
        otherRadioInput.value = otherLanguageInput.value;
    }
}