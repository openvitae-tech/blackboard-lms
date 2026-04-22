import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["picker", "text"]

  syncToText() {
    this.textTarget.value = this.pickerTarget.value
  }

  syncToPicker() {
    const val = this.textTarget.value.trim()
    if (/^#[0-9A-Fa-f]{6}$/.test(val)) {
      this.pickerTarget.value = val
    }
  }
}
