import { Controller } from "@hotwired/stimulus"

// Keeps the "Continue to Video style" button disabled until both the
// title and prompt fields are filled in.
export default class extends Controller {
  static targets = ['title', 'prompt', 'submit']

  connect() {
    this.updateSubmit()
  }

  updateSubmit() {
    const hasTitle = this.hasTitleTarget ? this.titleTarget.value.trim().length > 0 : false
    const hasPrompt = this.hasPromptTarget ? this.promptTarget.value.trim().length > 0 : false
    const enabled = hasTitle && hasPrompt

    this.submitTarget.disabled = !enabled

    const inner = this.submitTarget.querySelector('[class*="btn-"]')
    if (inner) {
      inner.classList.toggle('btn-disabled', !enabled)
      inner.classList.toggle('btn-solid-primary-disabled', !enabled)
    }
  }
}
