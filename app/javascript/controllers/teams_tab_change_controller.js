import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["teamContent"];

  changeTab(event) {
    event.preventDefault();
    const selectedTab = event.currentTarget.dataset.tab;

    this.teamContentTargets.forEach((el) => {
      el.classList.toggle("hidden", el.dataset.tab !== selectedTab);
    });

    this.setActiveTab(selectedTab);
  }

  setActiveTab(activeTab) {
    const tabs = this.element.querySelectorAll("a[data-tab]");
    tabs.forEach((tab) => {
      tab.classList.toggle("active-border", tab.dataset.tab === activeTab);
    });
  }
}
