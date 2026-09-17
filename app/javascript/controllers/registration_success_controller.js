import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["video", "button"]

  connect() {
    this.started = false
    if (!this.element.open) this.element.showModal()
  }

  async play() {
    if (this.started) return
    this.started = true
    this.buttonTarget.disabled = true
    this.videoTarget.muted = false
    this.videoTarget.volume = 1

    try {
      await this.videoTarget.play()
      // Closing or navigating away while playback is starting must stop audio too.
      if (!this.element.open || !this.element.isConnected) this.stopVideo()
    } catch {
      // A failed video must not prevent continuing to the next step.
      this.finish()
    }
  }

  videoFailed() {
    if (this.started) this.finish()
  }

  finish() {
    this.stopVideo()
    this.element.close()
  }

  stopVideo() {
    if (this.hasVideoTarget) this.videoTarget.pause()
  }

  disconnect() {
    this.finish()
  }
}
