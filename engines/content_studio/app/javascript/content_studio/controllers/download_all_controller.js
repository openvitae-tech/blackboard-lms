import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { urls: Array }

  async download() {
    for (const url of this.urlsValue) {
      await this._downloadBlob(url)
    }
  }

  async _downloadBlob(url) {
    const response = await fetch(url)
    const disposition = response.headers.get('content-disposition') || ''
    const blob = await response.blob()
    const objectUrl = URL.createObjectURL(blob)

    const match = disposition.match(/filename="?([^";\n]+)"?/)
    const filename = match ? match[1] : url.split('/').slice(-2, -1)[0] || 'document'

    const a = document.createElement('a')
    a.href = objectUrl
    a.download = filename
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(objectUrl)
  }
}
