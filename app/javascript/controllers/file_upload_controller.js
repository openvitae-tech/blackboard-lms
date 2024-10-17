import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "logoInput",
    "bannerInput",
    "logoLabel",
    "bannerLabel",
    "uploadButton",
    "logoPreview",
    "bannerPreview",
    "logoPreviewContainer",
    "bannerPreviewContainer",
  ];

  connect() {
    this.logoInputTarget.addEventListener(
      "change",
      this.handleFileSelect.bind(this)
    );
    this.bannerInputTarget.addEventListener(
      "change",
      this.handleFileSelect.bind(this)
    );
  }

  handleFileSelect(event) {
    const file = event.target.files[0];
    const labelTarget =
      event.target === this.logoInputTarget
        ? this.logoLabelTarget
        : this.bannerLabelTarget;
    const previewContainerTarget =
      event.target === this.logoInputTarget
        ? this.logoPreviewContainerTarget
        : this.bannerPreviewContainerTarget;
    const previewTarget =
      event.target === this.logoInputTarget
        ? this.logoPreviewTarget
        : this.bannerPreviewTarget;

    labelTarget.textContent = file ? file.name : "No file chosen";

    if (file && file.type.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = () => {
        previewTarget.src = reader.result;
        previewContainerTarget.classList.remove("hidden");
      };
      reader.readAsDataURL(file);
    } else {
      previewContainerTarget.classList.add("hidden");
    }

    this.setButtonState();
  }
  resetInput(event) {
    const fileType = event.currentTarget.dataset.fileType;
    const inputTarget = this[`${fileType}InputTarget`];
    const previewTarget = this[`${fileType}PreviewContainerTarget`];
    const labelTarget = this[`${fileType}LabelTarget`];

    inputTarget.value = "";
    previewTarget.classList.add("hidden");
    labelTarget.textContent = "No file chosen";

    this.setButtonState();
  }
  setButtonState() {
    const bothFilesSelected =
      this.logoInputTarget.files.length > 0 &&
      this.bannerInputTarget.files.length > 0;
    const submitButton = this.uploadButtonTarget;

    if (bothFilesSelected) {
      submitButton.classList.remove("btn-default");
      submitButton.classList.add("btn-primary");
    } else {
      submitButton.classList.remove("btn-primary");
      submitButton.classList.add("btn-default");
    }
  }
}
