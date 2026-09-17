import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "message"]

  connect() {
    this.finished = false
    this.starting = false
    this.previousOverflow = document.body.style.overflow
    document.body.style.overflow = "hidden"
    if (!this.element.open) this.element.showModal()
    this.element.focus()
  }

  async play(event) {
    if (!this.element.open || this.finished) return
    event?.preventDefault()
    const video = this.videoTarget
    if (this.starting || !video.paused) return
    this.starting = true
    try {
      if (video.error) video.load()
      video.muted = false
      video.volume = 1
      await video.play()
      this.messageTarget.textContent = ""
    } catch {
      this.messageTarget.textContent =
        "No pudimos iniciar el video. Toca la pantalla para reintentar."
    } finally {
      this.starting = false
    }
  }

  preventClose(event) {
    event.preventDefault()
  }

  showError() {
    this.messageTarget.textContent =
      "No se pudo cargar el video. Revisa tu conexión y toca la pantalla para reintentar."
  }

  finish() {
    if (!this.videoTarget.ended || this.finished) return
    this.finished = true
    this.element.close()
    document.body.style.overflow = this.previousOverflow
    this.element.remove()
  }

  disconnect() {
    this.videoTarget.pause()
    document.body.style.overflow = this.previousOverflow
    if (this.element.open) this.element.close()
  }
}
