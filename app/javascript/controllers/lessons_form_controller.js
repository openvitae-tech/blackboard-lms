import { Controller } from "@hotwired/stimulus";
import { toggleButtonState } from "../utils/lessons";

export default class extends Controller {
  static targets = [
    "nestedRecordContainer",
    "nestedRecordTemplate",
    "uploadButton",
    "hasError"
    ];

  initialize() {
    this.videoFieldCount = 1;
    this.isValidForAddRecord = this.hasErrorTarget.value === "false" && this.data.get("actionName") !== "edit";
  }
  connect() {
    this.nestedRecordTemplate = this.nestedRecordTemplateTarget;
    this.nestedRecordContainer = this.nestedRecordContainerTarget;
    this.element.addEventListener("video-upload:stateChange", (event) => {
      this.videoFieldCount--;

      this.setButtonState(event.detail.isActive);
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
    const uploadButton = this.uploadButtonTarget;
    this.uploadButtonTarget
      .querySelector("#submit-button")
      .classList.add("btn-default");
    this.uploadButtonTarget
      .querySelector("#submit-button")
      .classList.remove("btn-primary");

    uploadButton.style.color = "";
  }
  setButtonState(isActive) {
    const uploadButton = this.uploadButtonTarget;
    if (isActive) {
      if (this.videoFieldCount === 0) {
        this.uploadButtonTarget
          .querySelector("#submit-button")
          .classList.remove("btn-default");
        this.uploadButtonTarget
          .querySelector("#submit-button")
          .classList.add("btn-primary");

        uploadButton.style.color = "#FFFFFF";
      }
    } else {
      this.resetButtonState();
    }
  }

  removeRecord(event) {
    event.preventDefault();

    const languageSection = event.target.closest(".field-group");
    languageSection.querySelector('[name*="_destroy"]').value = "1";
    languageSection.style.display = "none";

    this.videoFieldCount--;
    toggleButtonState();
  }
}
