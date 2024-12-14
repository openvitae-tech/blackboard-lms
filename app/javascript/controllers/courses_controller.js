import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["filters"]

  open_filter() {
    this.filtersTarget.classList.remove("hidden")
  }

  close_filter() {
    this.filtersTarget.classList.add("hidden")
  }

  form_submit(event) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    const formValues = {};

    formData.forEach((value, key) => {
      formValues[key] = formValues[key] ? [].concat(formValues[key], value) : value;
    });

    const queryParams = new URLSearchParams();

    Object.entries(formValues).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach(v => queryParams.append(key, v));
      } else {
        queryParams.append(key, value);
      }
    });

    Turbo.visit(`?${this.existingQueryString(formValues)}&${queryParams.toString()}`);
    this.close_filter()
  }

  existingQueryString(formValues) {
    const params = new URLSearchParams(window.location.search);
    const queryParts = [];

    const type = params.get("type");
    if (type) queryParts.push(`type=${encodeURIComponent(type)}`);

    if (formValues['term'] === undefined) {
      const term = params.get("term");
      if (term) queryParts.push(`term=${encodeURIComponent(term)}`);
    }

    if (formValues['tags[]'] === undefined) {
      const tags = params.getAll("tags[]");
      tags.forEach(tag => queryParts.push(`tags[]=${encodeURIComponent(tag)}`));
    }

    return queryParts.join('&');
  }

}
