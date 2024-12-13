import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput"];

  connect() {
    this.element.addEventListener("submit", this.updateUrl.bind(this));
  }

  updateUrl(event) {
    const fetchResponse = event.detail.fetchResponse
    history.pushState(
        { turbo_frame_history: true },
        "",
        fetchResponse.response.url
    )
    console.log(fetchResponse)
  }
}
