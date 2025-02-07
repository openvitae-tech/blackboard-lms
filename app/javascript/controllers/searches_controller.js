import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["form", "filters", "checkbox", "searchInput"];
  headers = {
    Accept: "text/vnd.turbo-stream.html",
    "Content-Type": "application/json",
  };

  openFilter() {
    this.filtersTarget.classList.remove("hidden");
    document.body.style.overflow = "hidden";
  }

  closeFilter() {
    this.filtersTarget.classList.add("hidden");
    document.body.style.overflow = "";
  }

  formSubmit(event) {
    event.preventDefault();

    const form = this.formTarget;
    const formData = new FormData(form);
    const formValues = {};

    // Convert formData to JSON
    for (const [key, value] of formData.entries()) {
      // If the key already exists, make it an array
      if (formValues[key]) {
        formValues[key] = [].concat(formValues[key], value);
      } else {
        formValues[key] = value;
      }
    }
    // Handle multiple checkboxes correctly
    if (formData.has("tags[]")) {
      formValues["tags"] = formData.getAll("tags[]"); // Ensures an array
      delete formValues["tags[]"]; // Remove redundant key
    }

    const queryParams = new URLSearchParams();

    Object.entries(formValues).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach((v) => queryParams.append(key, v));
      } else {
        queryParams.append(key, value);
      }
    });

    fetch(form.action, {
      method: "POST",
      headers: this.headers,
      body: JSON.stringify(formValues),
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html))
      .catch((error) => console.error(error));

    // this.closeFilter();
  }

  clearFilters(event) {
    event.preventDefault();

    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = false;
    });
  }

  removeTag(event) {
    event.preventDefault();
    const el = event.target.closest("a");
    const label = el.dataset.label;

    this.checkboxTargets.forEach((checkbox) => {
      if (checkbox.value === label) {
        checkbox.checked = false;
      }
    });

    el.remove();

    const newEvent = new Event("submit", { bubbles: true, cancelable: true });
    this.formTarget.dispatchEvent(newEvent);
  }

  clearSearch(event) {
    event.preventDefault();
    this.searchInputTarget.value = "";
    const newEvent = new Event("submit", { bubbles: true, cancelable: true });
    this.formTarget.dispatchEvent(newEvent);
  }
}
