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
    "hiddenBlobId",
    "durationField",
    "failedUploadMessage",
  ];

  connect() {
    this.fileInputTarget.addEventListener(
      "change",
      this.handleFileSelect.bind(this)
    );
    if (this.hiddenBlobIdTarget.value) {
      this.restoreUploadedVideo();
    }
  }
  restoreUploadedVideo() {
    const blobId = this.hiddenBlobIdTarget.value;
    if (!blobId) return;

    const url = this.hiddenBlobIdTarget.dataset.blobUrl;
    if (!url) return;

    this.videoPlayerTarget.src = url;
    this.videoUploaderTarget.classList.remove("hidden");

  }

  hasVideo() {
    return !!this.hiddenBlobIdTarget?.value || !!this.videoPlayerTarget?.src;
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
  setFile(file) {
    this.fileInputTarget.files = this.buildFileList(file);
    this.handleFileSelect({ target: { files: [file] } });
  }

  buildFileList(file) {
    const dataTransfer = new DataTransfer();
    dataTransfer.items.add(file);
    return dataTransfer.files;
  }

  loadVideo(file) {
    const videoURL = URL.createObjectURL(file);
    this.videoPlayerTarget.src = videoURL;

    const videoElement = this.videoPlayerTarget;
    videoElement.addEventListener("loadedmetadata", () => {
      const duration = videoElement.duration;
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

  removeVideoNameAttribute() {
    this.fileInputTarget.removeAttribute("name");
  }

  uploadFile(file) {
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
      } else {
        this.hiddenBlobIdTarget.value = blob.id;
      }
      this.dispatchUploadEvent();
    });
  }

  directUploadWillStoreFileWithXHR(request) {
    this.currentXHR = request;
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
