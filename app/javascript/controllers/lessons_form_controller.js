import { Controller } from "@hotwired/stimulus";
import store from "store";

export default class extends Controller {
  static targets = [
    "nestedRecordContainer",
    "nestedRecordTemplate",
    "uploadButton",
    "hasError",
  ];

  initialize() {
    this.videoFieldCount = 0;
    this.isValidForAddRecord =
      this.hasErrorTarget.value === "false" &&
      this.data.get("actionName") !== "edit";
  }

  connect() {
    this.nestedRecordTemplate = this.nestedRecordTemplateTarget;
    this.nestedRecordContainer = this.nestedRecordContainerTarget;

    this.element.addEventListener("upload:changed", (event) => {
      event.detail.shouldDecreaseCount && this.videoFieldCount--;
      this.updateButtonState();
    });

    this.isValidForAddRecord && this.addRecord();
  }

  addRecord() {
    const newNode = this.nestedRecordTemplate.content.cloneNode(true);
    this.replaceNewIndex(newNode);
    this.nestedRecordContainer.appendChild(newNode);
    this.videoFieldCount++;
    this.resetButtonState();
  }

  replaceNewIndex(obj) {
    const timestamp = new Date().getTime();

    obj.querySelectorAll("input, select, textarea").forEach((field) => {
      field.id = new Date().getTime();
      field.name = field.name.replace("new-index", timestamp);
    });
  }

  resetButtonState() {
    this.uploadButtonTarget.classList.add("disabled");
  }

  setButtonState() {
    if (this.videoFieldCount === 0) {
      this.uploadButtonTarget.classList.remove("disabled");
    }
  }

  removeRecord(event) {
    event.preventDefault();

    const languageSection = event.target.closest(".field-group");
    languageSection.querySelector('[name*="_destroy"]').value = "1";
    languageSection.style.display = "none";

    if (this.videoFieldCount > 0) {
      this.videoFieldCount--;
    }

    this.setButtonState();
    store.removeUpload();
    this.updateButtonState();
  }

  updateButtonState() {
    if (store.hasPendingUploads()) {
      this.uploadButtonTarget.classList.add("disabled");
    } else {
      this.videoFieldCount === 0 &&
        this.uploadButtonTarget.classList.remove("disabled");
    }
  }
}
