import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
    static targets = ["filters", "checkbox", "searchInput"]
    headers = { 'Accept' : 'text/vnd.turbo-stream.html' , "Content-Type": "application/json"}

    connect() {
        const url =  this.getUrl();

        if (url.searchParams.has('clear_search')) {
            this.searchInputTarget.focus();
            url.searchParams.delete('clear_search');
            Turbo.navigator.history.push(url);
        }
    }

    openFilter() {
        this.filtersTarget.classList.remove("hidden")
        document.body.style.overflow = "hidden";
    }

    closeFilter() {
        this.filtersTarget.classList.add("hidden")
        document.body.style.overflow = "";
    }

    formSubmit(event) {
        console.log("Searching")
        event.preventDefault();

        const form = event.target;
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
                value.forEach(v => queryParams.append(key, v));
            } else {
                queryParams.append(key, value);
            }
        });

        fetch(form.action, { method: 'POST', headers: this.headers, body: JSON.stringify(formValues)})
            .then(response => response.text())
            .then(html => Turbo.renderStreamMessage(html))
            .catch(error => console.log(error))


        // Turbo.visit(window.location.origin + `/courses?${this.existingQueryString(formValues)}&${queryParams.toString()}`);
        this.closeFilter();
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

        if (formValues['tags[]'] === undefined && Object.keys(formValues).length>0) {
            const tags = params.getAll("tags[]");
            tags.forEach(tag => queryParts.push(`tags[]=${encodeURIComponent(tag)}`));
        }

        return queryParts.join('&');
    }

    clearFilters(event) {
        event.preventDefault();

        this.checkboxTargets.forEach(checkbox => {
            checkbox.checked = false;
        });
    }

    clearSearch() {
        this.searchInputTarget.value = "";
        const url = this.getUrl();

        url.searchParams.delete('term');
        url.searchParams.set('clear_search', 'true');
        Turbo.visit(url);
    }

    getUrl() {
        return new URL(window.location.href);
    }
}
