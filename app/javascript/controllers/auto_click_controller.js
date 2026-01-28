import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tabItem"];

  connect() {
    requestAnimationFrame(() => {
      if (this.hasTabItemTarget) {
        this.tabItemTarget.click()
      }
    })    
  }
}
