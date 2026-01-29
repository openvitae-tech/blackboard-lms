import { Controller } from "@hotwired/stimulus";
import store from "store";

export default class extends Controller {
  static outlets = ["video-upload"];

  static targets = [
    "nestedRecordContainer",
    "nestedRecordTemplate",
    "uploadButtonDisabled",
    "uploadButtonEnabled",
    "hasError",
    "videoInput",
    "titleInput",
    "languageSelect",
    "languageError",
    "destroyField"
  ];

  initialize() {
    this.videoFieldCount = 0;
    this.hasLanguageConflict = false;
    this.isValidForAddRecord =
      this.hasErrorTarget.value === "false" &&
      this.data.get("actionName") !== "edit";
  }

  connect() {
    this.nestedRecordTemplate = this.nestedRecordTemplateTarget;
    this.nestedRecordContainer = this.nestedRecordContainerTarget;

    this.element.addEventListener("upload:changed", () => {
      this.updateButtonState();
    });

    this.updateLanguageOptions();
    this.updateButtonState();
  }

  getSelectedLanguages(exceptSelect = null) {
    return this.languageSelectTargets
      .filter(select => {
        if (select === exceptSelect) return false;

        const fieldGroup = select.closest(".field-group");

        const destroyInput = this.getDestroyFieldFor(fieldGroup);
        return destroyInput?.value !== "1";
      })
      .map(select => select.value)
      .filter(Boolean);
  }

  getDestroyFieldFor(group) {
    return this.destroyFieldTargets.find(input =>
      group.contains(input)
    );
  }

  titleChanged() {
    this.updateButtonState();
  }

  openFilePicker() {
    this.videoInputTarget.click();
  }

  videoSelected(event) {
    const file = event.target.files[0];
    if (!file) return;

    const newNode = this.nestedRecordTemplate.content.cloneNode(true);
    this.replaceNewIndex(newNode);
    this.nestedRecordContainer.appendChild(newNode);

    const record = this.nestedRecordContainer.lastElementChild;
    this.setDefaultLanguageFor(record);
    const outlet = this.videoUploadOutlets.find(outlet =>
      record.contains(outlet.element)
    );

    outlet?.setFile(file);

    this.videoInputTarget.value = "";
    this.videoFieldCount++;
    this.updateLanguageOptions();
    this.updateButtonState();
  }

  languageChanged() {
    this.updateLanguageOptions();
  }

  removeRecord(event) {
    event.preventDefault();

    const languageSection = event.target.closest(".field-group");
    const destroyInput = this.getDestroyFieldFor(languageSection);
    destroyInput.value = "1";
    languageSection.style.display = "none";

    if (this.videoFieldCount > 0) {
      this.videoFieldCount--;
    }

    store.removeUpload();
    this.updateLanguageOptions();
    this.updateButtonState();
  }

  setDefaultLanguageFor(record) {
    const select = record.querySelector(
      '[data-lessons-form-target="languageSelect"]'
    );
    if (!select) return;

    const usedLanguages = new Set(this.getSelectedLanguages(select));

    if (!usedLanguages.has("english")) {
      select.value = "english";
      select.dispatchEvent(new Event("change", { bubbles: true }));
      return;
    }

    const availableOption = Array.from(select.options).find(
      opt => opt.value && !usedLanguages.has(opt.value)
    );

    if (availableOption) {
      select.value = availableOption.value;
      select.dispatchEvent(new Event("change", { bubbles: true }));

    }
  }

  updateLanguageOptions() {
    const selectedLanguages = this.getSelectedLanguages();
    const counts = {};

    selectedLanguages.forEach(lang => {
      counts[lang] = (counts[lang] || 0) + 1;
    });

    let hasConflict = false;

    this.languageSelectTargets.forEach((select, index) => {
      const lang = select.value;
      const errorEl = this.languageErrorTargets[index];

      if (lang && counts[lang] > 1) {
        errorEl.classList.remove("hidden");
        hasConflict = true;
      } else {
        errorEl.classList.add("hidden");
      }
    });

    this.hasLanguageConflict = hasConflict;
    this.updateButtonState();
  }

  hasVideo() {
    return Array.from(this.nestedRecordContainerTarget.children).some(group => {
      const destroyInput = this.getDestroyFieldFor(group);
      if (destroyInput?.value === "1") return false;

      const outlet = this.videoUploadOutlets.find(o =>
        group.contains(o.element)
      );

      if (outlet) return outlet.hasVideo();

      return !!group.querySelector("iframe, video");
    });
  }

  updateButtonState() {
    const hasTitle =
      this.titleInputTarget &&
      this.titleInputTarget.value.trim().length > 0;

    const hasVideo = this.hasVideo();
    const hasPendingUploads = store.hasPendingUploads();

    const shouldDisable =
      !hasTitle ||
      !hasVideo ||
      hasPendingUploads ||
      this.hasLanguageConflict;

    if (shouldDisable) {
      this.uploadButtonEnabledTarget.classList.add("hidden");
      this.uploadButtonDisabledTarget.classList.remove("hidden");
    } else {
      this.uploadButtonDisabledTarget.classList.add("hidden");
      this.uploadButtonEnabledTarget.classList.remove("hidden");
    }
  }

  replaceNewIndex(obj) {
    const timestamp = Date.now();
    obj.querySelectorAll("input, select, textarea").forEach((field, index) => {
      field.id = `${timestamp}-${index}`;
      field.name = field.name.replace("new-index", timestamp);
    });
  }
}
