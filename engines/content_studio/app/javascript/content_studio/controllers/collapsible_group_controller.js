import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["collapseBtn", "expandBtn"]

  collapseAll() {
    window.dispatchEvent(new CustomEvent('collapsible:close-all'))
    this.collapseBtnTarget.classList.add('hidden')
    this.expandBtnTarget.classList.remove('hidden')
  }

  expandAll() {
    window.dispatchEvent(new CustomEvent('collapsible:open-all'))
    this.collapseBtnTarget.classList.remove('hidden')
    this.expandBtnTarget.classList.add('hidden')
  }
}
