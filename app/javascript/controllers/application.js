import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
document.addEventListener("turbo:load", (event) => {
    const ga_id = document.querySelector("meta[name='google-analytics-id']").content;
    if (ga_id) {
        window.dataLayer = window.dataLayer || [];

        function gtag() {
            dataLayer.push(arguments);
        }

        gtag('js', new Date());

        gtag('config', ga_id);
    }
});