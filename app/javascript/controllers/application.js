import { Application } from "@hotwired/stimulus"
import { GeistSans } from 'geist/font/sans'

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
