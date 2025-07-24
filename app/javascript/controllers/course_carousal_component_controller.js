import { Controller } from "@hotwired/stimulus";
import Logger from "utils/logger";

export default class extends Controller {

    static targets = ["loadPath", "courseCarousalBody"]

    connect() {
        this.target_id = this.courseCarousalBodyTarget.id;
        this.page = 1;
        this.queryUrl = new URL(this.loadPathTarget.href);
        this.headers = {
            Accept: "text/vnd.turbo-stream.html",
            'X_Target_Id' : this.target_id
        };
    }

    loadPrevPage(event) {
        const disabled = event.currentTarget.getAttribute("aria-disabled");
        if (disabled === "true") return;

        this.decrementPage()
        this.loadPage(this.pageUrl())
    }

    loadNextPage(event) {
        const disabled = event.currentTarget.getAttribute("aria-disabled");
        if (disabled === "true") return;

        this.incrementPage()
        this.loadPage(this.pageUrl())
    }

    loadPage(url) {
        fetch(url, {
            method: "GET",
            headers: this.headers,
        })
            .then((response) => response.text())
            .then((html) => Turbo.renderStreamMessage(html))
            .catch((error) => Logger.error(error));
    }

    decrementPage() {
        if (this.page > 1) {
            this.page = this.page - 1;
        }
    }

    incrementPage() {
        this.page = this.page + 1;
    }

    pageUrl() {
        this.queryUrl.searchParams.set('page', this.page)
        return `/searches/list${this.queryUrl.search}`;
    }
}