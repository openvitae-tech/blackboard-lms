import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "wrapper",
    "chooseFile",
    "fileInput",
    "selectedFileName",
    "preview",
    "previewContainer",
    "iconPreview",
    "fileName",
    "fileSize",
    "fileList",
    "imageItemTemplate",
    "docItemTemplate",
    "mediaItemTemplate"
  ];

  connect() {
    this.multipleFiles = new DataTransfer();
    this.fileInputTarget.addEventListener("change", (e) => {
      if (this.fileInputTarget.multiple) {
        this.handleMultipleFiles(e.target.files);
      } else {
        const file = e.target.files[0];
        this.updateFileName(file);
        this.showPreview(file);
        if (file) this.activate();
      }
    });
  }

  // ── Multiple-file mode ──────────────────────────────────────────────────

  handleMultipleFiles(newFiles) {
    Array.from(newFiles).forEach(file => {
      this.multipleFiles.items.add(file);
      this.appendFileItem(file);
    });
    this.fileInputTarget.files = this.multipleFiles.files;
  }

  appendFileItem(file) {
    const isMedia = file.type.startsWith("video/") ||
                    file.type.startsWith("audio/") ||
                    /\.(mp4|mov|avi|mkv|webm|mp3|wav|ogg)$/i.test(file.name);
    const isImage = file.type.startsWith("image/");

    let template;
    if (isMedia) {
      template = this.mediaItemTemplateTarget.content.cloneNode(true);
    } else if (isImage) {
      template = this.imageItemTemplateTarget.content.cloneNode(true);
    } else {
      template = this.docItemTemplateTarget.content.cloneNode(true);
    }

    const item = template.querySelector(".file-selector-list-item");
    item.dataset.fileName = file.name;
    item.querySelector(".file-selector-list-item-name").textContent = this.truncateFileName(file.name, 20);

    this.fileListTarget.appendChild(template);
  }

  removeListItem(event) {
    const item = event.currentTarget.closest(".file-selector-list-item");
    const fileName = item.dataset.fileName;

    const updated = new DataTransfer();
    Array.from(this.multipleFiles.files).forEach(f => {
      if (f.name !== fileName) updated.items.add(f);
    });
    this.multipleFiles = updated;
    this.fileInputTarget.files = updated.files;

    item.remove();
  }

  // ── Single-file mode ────────────────────────────────────────────────────

  activate() {
    if (!this.isErrorState()) {
      this.wrapperTarget.classList.add("file-selector-is-active");
    }
  }

  deactivate() {
    this.wrapperTarget.classList.remove("file-selector-is-active");
  }

  isErrorState() {
    return this.wrapperTarget.classList.contains("border-danger");
  }

  updateFileName(file) {
    this.clearError();
    this.chooseFileTarget.classList.add("hidden");
    this.selectedFileNameTarget.classList.remove("hidden");

    if (file) {
      const truncated = this.truncateFileName(file.name, 20);
      this.fileNameTarget.textContent = truncated;
      this.fileSizeTarget.textContent = this.formatFileSize(file.size);
    } else {
      this.fileNameTarget.textContent = "No file chosen";
      this.fileSizeTarget.textContent = "";
    }
  }

  truncateFileName(fileName, maxLength = 10) {
    const dotIndex = fileName.lastIndexOf(".");

    if (dotIndex === -1) {
      return fileName.length > maxLength
        ? fileName.slice(0, maxLength) + "..."
        : fileName;
    }

    const namePart = fileName.slice(0, dotIndex);
    const extension = fileName.slice(dotIndex);

    if (namePart.length <= maxLength) return fileName;

    return namePart.slice(0, maxLength) + "..." + extension;
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
    this.activate();

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
    this.wrapperTarget.classList.remove("file-selector-is-active");
  }

  chooseFile() {
    if (!this.chooseFileTarget.classList.contains("hidden")) {
      this.activate();
      this.fileInputTarget.click();
    }
  }
}
