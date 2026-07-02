import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tabItem"];
  static values = { index: { type: Number, default: 0 } };

  connect() {
    requestAnimationFrame(() => {
      const target = this.tabItemTargets[this.indexValue] ?? this.tabItemTargets[0];
      if (target) target.click();
    });
  }
}
