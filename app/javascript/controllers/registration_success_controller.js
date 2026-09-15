import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (!this.element.open) this.element.showModal()
  }

  disconnect() {
    this.element.close()
  }
}
