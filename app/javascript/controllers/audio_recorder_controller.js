import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-recorder"
export default class extends Controller {
  connect() {
    this.chunks = []
  }

  async start () {
    this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    console.log(this.stream)
    this.recorder = new MediaRecorder(this.stream)
    this.chunks = []
    this.recorder.ondataavailable = (event) => {
      this.chunks.push(event.data)
    }
    this.recorder.onstop = () => {}
    this.recorder.start()
    console.log(this.recorder.state)
  }

  stop () {
    if (this.recorder && this.recorder.state !== "inactive") {
      this.recorder.stop()
      }
    if (this.stream) {
      this.stream,getTracks().forEach(track => track.stop())
    }
    }
}
