import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["expanded", "collapsed", "icon"]

  toggle() {
    this.expandedTarget.classList.toggle("hidden")
    this.collapsedTarget.classList.toggle("hidden")
    this.iconTarget.classList.toggle("rotate-180")
  }
}