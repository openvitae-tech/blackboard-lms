import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileInput","videoUploader", "fileLabel", "videoPlayer", "fileSize", "duration"];

  connect() {
    this.fileInputTarget.addEventListener('change', this.handleFileSelect.bind(this));
  }

  handleFileSelect(event) {
    const file = event.target.files[0];

    if (file) {
      this.videoUploaderTarget.classList.remove("hidden");
      this.fileLabelTarget.textContent = this.truncateFileName(file.name, 20); 
      this.fileSizeTarget.textContent = this.formatBytes(file.size);
      this.loadVideo(file);
    } 
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
    videoElement.addEventListener('loadedmetadata', () => {
      const duration = videoElement.duration;
      this.durationTarget.textContent = this.formatTime(duration);
    });
  }

  formatBytes(bytes) {
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    if (bytes === 0) return '0 Bytes';
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return parseFloat((bytes / Math.pow(1024, i)).toFixed(2)) + ' ' + sizes[i];
  }

  formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs < 10 ? '0' + secs : secs}`;
  }
}
