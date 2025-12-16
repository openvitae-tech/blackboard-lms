import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { courseId: Number }

  upload(event) {
    const files = event.target.files
    if (files.length === 0) {
      return
    }

    const formData = new FormData()
    const token = document.querySelector('meta[name="csrf-token"]').content
    formData.append("authenticity_token", token)

    for (const file of files) {
      formData.append("course[materials][]", file)
    }

    fetch(`/courses/${this.courseIdValue}/materials`, {
      method: 'POST',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: formData
    })
    .then(response => {
      if (response.ok) {
        return response.text()
      } else {
        return Promise.reject(response)
      }
    })
    .then(html => {
        Turbo.renderStreamMessage(html);
    })
    .finally(() => {
      event.target.value = null;
    })
  }
}