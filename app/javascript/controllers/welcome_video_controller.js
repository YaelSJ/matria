import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video"]

  connect() {
    this.connected = true
    this.playingRequest = false
    this.playGreeting = this.playGreeting.bind(this)
    this.motionPreference = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.updateMotion = this.updateMotion.bind(this)
    this.motionPreference.addEventListener("change", this.updateMotion)
    this.videoTarget.muted = false
    this.videoTarget.volume = 1

    if (this.motionPreference.matches) {
      this.waitForInteraction()
    } else {
      this.playGreeting()
    }
  }

  async playGreeting(event) {
    if (event?.type === "keydown" && (event.repeat || event.ctrlKey || event.metaKey || event.altKey || event.key === "Escape")) return
    if (!this.connected || this.playingRequest) return

    this.playingRequest = true
    try {
      await this.videoTarget.play()
      if (this.connected) this.removeInteractionListeners()
    } catch (error) {
      // Browsers may require a click or key press before allowing audible playback.
      if (this.connected && error.name === "NotAllowedError") this.waitForInteraction()
    } finally {
      this.playingRequest = false
    }
  }

  waitForInteraction() {
    document.addEventListener("click", this.playGreeting)
    document.addEventListener("keydown", this.playGreeting)
  }

  removeInteractionListeners() {
    document.removeEventListener("click", this.playGreeting)
    document.removeEventListener("keydown", this.playGreeting)
  }

  updateMotion() {
    if (this.motionPreference.matches) {
      this.videoTarget.pause()
      this.waitForInteraction()
    }
  }

  disconnect() {
    this.connected = false
    this.removeInteractionListeners()
    this.motionPreference.removeEventListener("change", this.updateMotion)
    this.videoTarget.pause()
  }
}
