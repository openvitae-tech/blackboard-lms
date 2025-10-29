import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "chooseFile",
    "fileInput",
    "selectedFileName",
    "preview",
    "previewContainer",
    "iconPreview",
    "fileName",
    "fileSize"
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
    this.chooseFileTarget.classList.add("hidden");
    this.selectedFileNameTarget.classList.remove("hidden");

    if (file) {
      this.fileNameTarget.textContent = file.name;
      this.fileSizeTarget.textContent = this.formatFileSize(file.size);
    } else {
      this.fileNameTarget.textContent = "No file chosen";
      this.fileSizeTarget.textContent = "";
    }
  }

  formatFileSize(bytes) {
    if (bytes < 1024) return `${bytes} B`;
    if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
  }

  showPreview(file) {
    if (!file) return;

    const fileType = file.type || "";
    const fileName = file.name.toLowerCase();
    this.previewContainerTarget.classList.remove("hidden");

    if (this.previewTarget.src.startsWith("blob:")) {
      URL.revokeObjectURL(this.previewTarget.src);
    }

    if (fileType.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = () => {
        this.previewTarget.src = reader.result;
      };
      reader.onerror = () => this.showError("Failed to load file preview");
      reader.readAsDataURL(file);

    } else if (fileType.startsWith("video/") || /\.(mp4|mov|avi|mkv|webm)$/i.test(fileName)) {
      const blobURL = URL.createObjectURL(file);
      this.previewTarget.src = blobURL;
      this.previewTarget.load();
      this.previewTarget.controls = false; 
      this.previewTarget.muted = true; 
      this.previewTarget.autoplay = false; 

    } else {
      this.previewTarget.src = "";
    }
  }

  showError(message) {
    this.resetInput();
    this.fileNameTarget.innerText = message;
    this.fileNameTarget.style.color = "red";
  }

  clearError() {
    this.fileNameTarget.textContent = "No file chosen";
    this.fileNameTarget.style.color = "";
  }

  resetInput() {
    if (this.hasPreviewTarget && this.previewTarget.src.startsWith("blob:")) {
      URL.revokeObjectURL(this.previewTarget.src);
    }

    this.fileInputTarget.value = "";
    this.fileNameTarget.textContent = "";
    this.fileSizeTarget.textContent = "";
    this.selectedFileNameTarget.classList.add("hidden");
    this.previewContainerTarget.classList.add("hidden");
    if (this.hasPreviewTarget && this.previewTarget.src) {
      this.previewTarget.src = "";
    } 
    this.chooseFileTarget.classList.remove("hidden");
  }

  chooseFile() {
    if (!this.chooseFileTarget.classList.contains("hidden")) {
      this.fileInputTarget.click();
    }
  }
}