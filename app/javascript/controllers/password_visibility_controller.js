import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "button", "icon"]

  connect() {
    this.buttonTarget.hidden = false
  }

  toggle() {
    const visible = this.inputTarget.type === "password"
    this.inputTarget.type = visible ? "text" : "password"
    this.buttonTarget.setAttribute("aria-pressed", String(visible))
    this.buttonTarget.setAttribute("aria-label", visible ? "Ocultar contraseña" : "Mostrar contraseña")
    this.iconTarget.classList.toggle("fa-eye", visible)
    this.iconTarget.classList.toggle("fa-eye-slash", !visible)
  }
}
