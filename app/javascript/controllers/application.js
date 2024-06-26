import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
document.addEventListener("turbo:load", (event) => {
    const metaEl = document.querySelector("meta[name='google-analytics-id']");
    if (metaEl) {
        const ga_id = metaEl.content;
        window.dataLayer = window.dataLayer || [];

        function gtag() {
            dataLayer.push(arguments);
        }

        gtag('js', new Date());

        gtag('config', ga_id);
    }
});