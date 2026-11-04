import { Controller } from "@hotwired/stimulus"

// Toggles between "Upload Document" and "Write a Prompt" modes on the
// microlesson creation wizard's first step.
export default class extends Controller {
  static targets = ['uploadSection', 'promptSection', 'uploadTab', 'promptTab', 'modeField']

  connect() {
    this.setMode('upload')
  }

  showUpload() {
    this.setMode('upload')
  }

  showPrompt() {
    this.setMode('prompt')
  }

  setMode(mode) {
    const isUpload = mode === 'upload'

    this.uploadSectionTarget.classList.toggle('hidden', !isUpload)
    this.promptSectionTarget.classList.toggle('hidden', isUpload)
    this.modeFieldTarget.value = mode

    this.uploadTabTarget.classList.toggle('bg-primary', isUpload)
    this.uploadTabTarget.classList.toggle('text-white', isUpload)
    this.uploadTabTarget.classList.toggle('border-primary', isUpload)
    this.uploadTabTarget.classList.toggle('bg-white', !isUpload)
    this.uploadTabTarget.classList.toggle('text-letter-color', !isUpload)
    this.uploadTabTarget.classList.toggle('border-line-colour-light', !isUpload)

    this.promptTabTarget.classList.toggle('bg-primary', !isUpload)
    this.promptTabTarget.classList.toggle('text-white', !isUpload)
    this.promptTabTarget.classList.toggle('border-primary', !isUpload)
    this.promptTabTarget.classList.toggle('bg-white', isUpload)
    this.promptTabTarget.classList.toggle('text-letter-color', isUpload)
    this.promptTabTarget.classList.toggle('border-line-colour-light', isUpload)
  }
}
