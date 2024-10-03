import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["teamContent", "allUsersSection", "showAllLink"];
  changeTab(event) {
    event.preventDefault();
    const selectedTab = event.currentTarget.dataset.tab;
    this.showTab(selectedTab);
    this.setActiveTab(selectedTab);
  }

  showTab(tab) {
    this.teamContentTargets.forEach((el) => {
      el.classList.add("hidden");
    });
    const selectedContent = this.teamContentTargets.find(target => target.dataset.tab === tab);
    if (selectedContent) {
      selectedContent.classList.remove("hidden");
    }
  }
  setActiveTab(activeTab) {
    const tabs = this.element.querySelectorAll("a[data-tab]");
    tabs.forEach((tab) => {
      tab.classList.remove("active-border");
    });
    const activeTabElement = this.element.querySelector(
      `a[data-tab="${activeTab}"]`
    );
    if (activeTabElement) {
      activeTabElement.classList.add("active-border");
    }
  }
 
}
