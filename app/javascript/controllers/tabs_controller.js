import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabItem", "panelItem"]
  static classes = ["active"]
  static values = { panelHtml: String }

  connect() {
    this.tabItemTarget.classList.add(...this.activeClasses)
  }
  select(event) {
    const currentTabIndex = this.tabItemTargets.indexOf(event.currentTarget)
    
    this.tabItemTargets.forEach((item, idx) => {
      if (currentTabIndex === idx) {
        item.classList.add(...this.activeClasses)
      } else {
        item.classList.remove(...this.activeClasses)
      }
    });
    this.panelItemTargets.forEach((panel, idx) => {
      if (currentTabIndex === idx) {
        panel.classList.remove('hidden')
      } else {
        panel.classList.add('hidden')
      }
    })
  }
}
