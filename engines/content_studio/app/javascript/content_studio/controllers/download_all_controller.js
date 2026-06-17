import { Controller } from "@hotwired/stimulus"

const STAGGER_MS = 500

export default class extends Controller {
  static values = { urls: Array }

  download() {
    this.urlsValue.forEach((url, index) => {
      setTimeout(() => {
        const a = document.createElement('a')
        a.href = url
        a.download = ''
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
      }, index * STAGGER_MS)
    })
  }
}
