import { Controller } from "@hotwired/stimulus"

const REFRESH_INTERVAL_MS = 1000;

// Periodically refresh the URL
//
// data: { controller: 'refresh', refresh_src_value: request.path }
//
export default class extends Controller {
  static values = {
    src: String
  }

  connect() {
    console.log('connect');
    this.timeout = setInterval(() => {
      console.log('timeout');

      // Disconnect when the answer frame is shown
      if (this.element.querySelector('#answer')) {
        clearTimeout(this.timeout);
        return;
      }

      this.element.setAttribute('src', this.srcValue);
      this.element.reload();
    }, REFRESH_INTERVAL_MS);
  }

  disconnect() {
    console.log('connect');
    clearInterval(this.timeout)
  }
}
