import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage"
import { toggleButtonState } from "../utils/lessons";
import store from "../store";

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
    "failedUploadMessage"
  ];

  connect() {
    this.fileInputTarget.addEventListener(
      "change",
      this.handleFileSelect.bind(this)
    );
    store.pendingCount = 0;
  }

  handleFileSelect(event) {
    const file = event.target.files[0];
    if (file) {
      this.videoUploaderTarget.classList.remove("hidden");
      this.fileLabelTarget.textContent = this.truncateFileName(file.name, 20);
      this.fileSizeTarget.textContent = this.formatBytes(file.size);
      this.loadVideo(file);
    }

    this.uploadFile(file)
    this.checkActiveState();
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

  checkActiveState() {
    const hasVideo = this.fileInputTarget.files.length > 0;

    const event = new CustomEvent("video-upload:stateChange", {
      detail: { isActive: hasVideo },
      bubbles: true,
      composed: true,
    });

    this.element.dispatchEvent(event);
  }

  toggleCancelUploadButtons(hidden) {
    this.hideCancelUploadButtonTargets.forEach(item => {
      item.hidden = hidden;
    });
  }

  removeVideoNameAttribute() {
    this.fileInputTarget.removeAttribute("name")
  }

  uploadFile(file) {
    this.toggleCancelUploadButtons(false);
    store.pendingCount += 1;
    toggleButtonState({ type: "disabled", pendingCount: store.pendingCount });

    const upload = new DirectUpload(file, '/direct_uploads?service=video', this);

    upload.create((error,blob) => {
      store.pendingCount -= 1;
      toggleButtonState({ pendingCount: store.pendingCount });
      if (error) {
        this.failedUploadMessageTarget.classList.remove("hidden");
        this.uploadControlsTarget.classList.add("hidden");
      } else {
        this.hiddenBlobIdTarget.value = blob.id;
        this.toggleCancelUploadButtons(true);
      }
    });
  }

  directUploadWillStoreFileWithXHR(request) {
    this.currentXHR = request;

    request.upload.addEventListener("progress", (event) => this.directUploadDidProgress(event));
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
      store.pendingCount -= 1;
      toggleButtonState({ pendingCount: store.pendingCount  });
    }
  }

  resetUploader() {
    this.videoUploaderTarget.classList.add('hidden');
    this.fileLabelTarget.textContent = 'No file chosen';
    this.hiddenBlobIdTarget.value = '';
    this.fileInputTarget.value = '';
  }
}
