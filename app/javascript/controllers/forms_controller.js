import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "fileInput",
    "selectedFileName",
    "preview",
    "previewContainer",
  ];

  connect() {
    this.fileInputTarget.addEventListener("change", (e) => {
      const file = e.target.files[0];
      this.updateFileName(file);
      this.showPreview(file);
    });
  }

  updateFileName(file) {
    this.clearError();
    const fileName = file ? file.name : "No file chosen";
    this.selectedFileNameTarget.innerText = fileName;
  }

  showPreview(file) {
    const fileType = this.fileInputTarget.dataset.fileType;

    if (file) {
      if (this.hasPreviewContainerTarget) {
        if (file.type.startsWith("image/")) {
          const reader = new FileReader();
          reader.onload = () => {
            this.previewTarget.src = reader.result;
            this.previewContainerTarget.classList.remove("hidden");
          };
          reader.readAsDataURL(file);
        } else if (file.type.startsWith("video/")) {
          this.showError("Video files are not allowed.");
        } else {
          this.showError("Only image files are allowed.");
        }
      } else {
        if (
          file.type === "text/csv" ||
          file.type === "text/plain" ||
          file.type === "application/json"
        ) {
          reader.readAsDataURL(file);
        } else {
          this.showError("Only CSV files are allowed.");
        }
      }
    }
  }

  showError(message) {
    this.resetInput();
    this.selectedFileNameTarget.innerText = message;
    this.selectedFileNameTarget.style.color = "red";
  }
  clearError() {
    this.selectedFileNameTarget.innerText = "No file chosen";
    this.selectedFileNameTarget.style.color = "";
  }
  resetInput() {
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.classList.add("hidden");
      this.previewTarget.src = "";
    }

    this.fileInputTarget.value = "";
    this.selectedFileNameTarget.innerText = "No file chosen";
  }

  chooseFile(event) {
    this.fileInputTarget.click();
  }
}
