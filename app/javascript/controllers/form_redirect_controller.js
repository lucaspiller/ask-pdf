import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Update the URL when a form redirects
//
// Add these attributes to a form element:
//
//   data: { controller: 'form-redirect', action: 'turbo:submit-end->form-redirect#next' }
//
export default class extends Controller {
  next(event) {
    if (event.detail.success) {
      const fetchResponse = event.detail.fetchResponse

      history.pushState(
        { turbo_frame_history: true },
        "",
        fetchResponse.response.url
      )

      Turbo.visit(fetchResponse.response.url)
    }
  }
}