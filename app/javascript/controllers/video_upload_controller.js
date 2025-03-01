import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";
import store from "store";

export default class extends Controller {
  static targets = [
    "fileInput",
    "urlInput",
    "videoUploader",
    "fileLabel",
    "videoPlayer",
    "fileSize",
    "duration",
    "progressBar",
    "progressText",
    "hiddenBlobId",
    "hideCancelUploadButton",
    "durationField",
    "uploadControls",
    "failedUploadMessage",
  ];

  connect() {
    this.fileInputTarget.addEventListener(
      "change",
      this.handleFileSelect.bind(this)
    );
  }

  handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
      this.videoUploaderTarget.classList.remove("hidden");
      this.fileLabelTarget.textContent = this.truncateFileName(file.name, 20);
      this.fileSizeTarget.textContent = this.formatBytes(file.size);
      this.loadVideo(file);
    }

    this.uploadFile(file);
  }

  truncateFileName(name, maxLength) {
    if (name.length > maxLength) {
      return name.slice(0, maxLength) + "...";
    }
    return name;
  }

  loadVideo(file) {
    const videoURL = URL.createObjectURL(file);
    this.videoPlayerTarget.src = videoURL;

    const videoElement = this.videoPlayerTarget;
    videoElement.addEventListener("loadedmetadata", () => {
      const duration = videoElement.duration;
      this.durationTarget.textContent = this.formatTime(duration);
      this.durationFieldTarget.value = duration;
    });
  }

  formatBytes(bytes) {
    const sizes = ["Bytes", "KB", "MB", "GB"];
    if (bytes === 0) return "0 Bytes";
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return parseFloat((bytes / Math.pow(1024, i)).toFixed(2)) + " " + sizes[i];
  }

  formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs < 10 ? "0" + secs : secs}`;
  }

  toggleCancelUploadButtons(hidden) {
    this.hideCancelUploadButtonTargets.forEach((item) => {
      item.hidden = hidden;
    });
  }

  removeVideoNameAttribute() {
    this.fileInputTarget.removeAttribute("name");
  }

  uploadFile(file) {
    this.toggleCancelUploadButtons(false);
    store.addUpload();

    const upload = new DirectUpload(
      file,
      "/direct_uploads?service=video",
      this
    );

    upload.create((error, blob) => {
      store.removeUpload();
      if (error) {
        this.failedUploadMessageTarget.classList.remove("hidden");
        this.uploadControlsTarget.classList.add("hidden");
      } else {
        this.hiddenBlobIdTarget.value = blob.id;
        this.toggleCancelUploadButtons(true);
      }
      this.dispatchUploadEvent();
    });
  }

  directUploadWillStoreFileWithXHR(request) {
    this.currentXHR = request;

    request.upload.addEventListener("progress", (event) =>
      this.directUploadDidProgress(event)
    );
  }

  directUploadDidProgress(event) {
    const progress = (event.loaded / event.total) * 100;
    this.progressBarTarget.style.width = `${progress}%`;
    this.progressTextTarget.textContent = `${Math.round(progress)}%`;
  }

  abortUpload(event) {
    event.preventDefault();

    if (this.currentXHR) {
      this.currentXHR.abort();
      this.currentXHR = null;
      this.resetUploader();
      store.removeUpload();
      this.dispatchUploadEvent(false);
    }
  }

  resetUploader() {
    this.videoUploaderTarget.classList.add("hidden");
    this.fileLabelTarget.textContent = "No file chosen";
    this.hiddenBlobIdTarget.value = "";
    this.fileInputTarget.value = "";
  }

  dispatchUploadEvent(shouldDecreaseCount = true) {
    const event = new CustomEvent("upload:changed", {
      detail: {
        hasPendingUploads: store.hasPendingUploads(),
        shouldDecreaseCount,
      },
      bubbles: true,
    });
    this.element.dispatchEvent(event);
  }
}
