import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="audio-recorder"
export default class extends Controller {

  static targets = ["audioInput", "startButton", "stopButton"]

  connect() {
    this.chunks = []
  }

  async start () {
    this.startButtonTarget.disabled = true
    this.stopButtonTarget.disabled = false
    this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
    console.log(this.stream)
    this.recorder = new MediaRecorder(this.stream)
    this.chunks = []
    this.recorder.ondataavailable = (event) => {
      this.chunks.push(event.data)
    }
    this.recorder.onstop = () => {
      const audioBlob = new Blob(this.chunks, {
        type: this.recorder.mimeType
      })
      const audioFile = new File(
        [audioBlob],
        "grabacion.webm",
        { type: audioBlob.type }
      )
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(audioFile)
      this.audioInputTarget.files = dataTransfer.files

      console.log(audioBlob)

      this.stream.getTracks().forEach(track => track.stop())
    }
    this.recorder.start()
    console.log(this.recorder.state)
  }

  stop () {
    if (this.recorder && this.recorder.state !== "inactive") {
      this.recorder.stop()
      this.startButtonTarget.disabled = false
      this.stopButtonTarget.disabled = true
      }
    }
}
