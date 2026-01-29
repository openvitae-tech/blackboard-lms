import { Application } from "@hotwired/stimulus";
import * as ActiveStorage from "@rails/activestorage";

const application = Application.start();
ActiveStorage.start();

// Configure Stimulus development experience
application.debug = false;
window.Stimulus = application;

export { application };
document.addEventListener("turbo:load", (event) => {
  const metaEl = document.querySelector("meta[name='google-analytics-id']");
  if (metaEl) {
    const ga_id = metaEl.content;
    window.dataLayer = window.dataLayer || [];

    function gtag() {
      dataLayer.push(arguments);
    }

    gtag("js", new Date());

    gtag("config", ga_id);
  }

  document.querySelectorAll("trix-editor").forEach((editor) => {
    if (!editor.dataset.trixInitialized) {
      editor.dataset.trixInitialized = "true";
    }
  });

});

Turbo.StreamActions.redirect_to = function () {
  const url = this.getAttribute("url") || "/";
  Turbo.visit(url);
};
