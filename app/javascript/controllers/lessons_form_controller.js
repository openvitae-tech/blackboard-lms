import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "nestedRecordContainer",
    "nestedRecordTemplate",
    "uploadButton",
  ];
  initialize() {
    this.videoFieldCount = 1;
  }
  connect() {
    this.nestedRecordTemplate = this.nestedRecordTemplateTarget;
    this.nestedRecordContainer = this.nestedRecordContainerTarget;
    this.element.addEventListener("video-upload:stateChange", (event) => {
      this.videoFieldCount--;

      this.setButtonState(event.detail.isActive);
    });
  }

  addRecord(event) {
    const newNode = this.nestedRecordTemplate.content.cloneNode(true);
    this.replaceNewIndex(newNode);
    this.nestedRecordContainer.appendChild(newNode);
    this.videoFieldCount++;
    this.resetButtonState();
  }

  removeRecord(event) {
    const parent = event.target.parentElement.parentElement.parentElement;
    const fileInput = parent.querySelector("input[type='file']");
    parent.querySelector("input[type='hidden']").value = true;
    parent.classList.add("hidden");
    if (fileInput) {
      fileInput.value = "";
      this.videoFieldCount--;
    }
    this.setButtonState(true);
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
}
