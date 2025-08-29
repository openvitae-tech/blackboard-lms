import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["button"];

  setPageParam() {
    const nextUrl = this.buttonTarget.getAttribute("href");
    if (!nextUrl) return;
      window.history.replaceState({}, "", nextUrl);
  }
}