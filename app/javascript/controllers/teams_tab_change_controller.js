import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tabContent", "tabLink"];

  changeTab(event) {
    event.preventDefault();
    const selectedTab = event.currentTarget.dataset.tab;

    this.tabContentTargets.forEach((el) => {
      el.classList.toggle("hidden", el.dataset.tab !== selectedTab);
    });

    this.setActiveTab(selectedTab);
  }

  setActiveTab(activeTab) {
    this.tabLinkTargets.forEach((link) => {
      const isActive = link.dataset.tab === activeTab;
      link.classList.toggle("active-border", isActive);
    });
  }
}
