import { Controller } from "@hotwired/stimulus";
import store from "store";

export default class extends Controller {
  static targets = [
    "nestedRecordContainer",
    "nestedRecordTemplate",
    "uploadButton",
    "hasError",
    "videoInput",
    "titleInput"
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

    this.element.addEventListener("upload:changed", () => {
      this.updateButtonState();
    });

    this.updateButtonState();
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
    const videoUploadElement = record.querySelector(
      '[data-controller="video-upload"]'
    );

    const tryAttachFile = (attempts = 5) => {
      const controller =
        this.application.getControllerForElementAndIdentifier(
          videoUploadElement,
          "video-upload"
        );

      if (controller) {
        controller.setFile(file);
        return;
      }

      if (attempts > 0) {
        requestAnimationFrame(() => tryAttachFile(attempts - 1));
      }
    };

    tryAttachFile();

    this.videoInputTarget.value = "";
    this.videoFieldCount++;
    this.updateButtonState();
  }

  replaceNewIndex(obj) {
    const timestamp = Date.now();

    obj.querySelectorAll("input, select, textarea").forEach((field, index) => {
      field.id = `${timestamp}-${index}`;
      field.name = field.name.replace("new-index", timestamp);
    });
  }


  removeRecord(event) {
    event.preventDefault();

    const languageSection = event.target.closest(".field-group");
    languageSection.querySelector('[name*="_destroy"]').value = "1";
    languageSection.style.display = "none";

    if (this.videoFieldCount > 0) {
      this.videoFieldCount--;
    }

    store.removeUpload();
    this.updateButtonState();
  }

  hasVideo() {
    const existingVideo = this.nestedRecordContainerTarget.querySelector(
      '.field-group video[src]'
    );
    if (existingVideo) return true;

    const uploadedVideo = this.nestedRecordContainerTarget.querySelector(
      '[data-video-upload-target="hiddenBlobId"][value]'
    );

    return !!uploadedVideo;
  }

  updateButtonState() {
    const hasTitle =
      this.titleInputTarget &&
      this.titleInputTarget.value.trim().length > 0;

    const hasVideo = this.hasVideo();
    const hasPendingUploads = store.hasPendingUploads();

    const shouldDisable = !hasTitle || !hasVideo || hasPendingUploads;

    this.uploadButtonTarget.classList.toggle("disabled", shouldDisable);
    this.uploadButtonTarget.disabled = shouldDisable;
  }
}
