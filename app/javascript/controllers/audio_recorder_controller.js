import { Controller } from "@hotwired/stimulus"
import toWav from "audiobuffer-to-wav"

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
    this.recorder = new MediaRecorder(this.stream)
    this.chunks = []
    this.recorder.ondataavailable = (event) => {
      this.chunks.push(event.data)
    }
    this.recorder.onstop = async () => {
      const audioBlob = new Blob(this.chunks, {
        type: this.recorder.mimeType
      })
      const wavBlob = await this.convertToWav(audioBlob)
      const audioFile = new File(
        [wavBlob],
        "grabacion.wav",
        { type: "audio/wav" }
      )
      const dataTransfer = new DataTransfer()
      dataTransfer.items.add(audioFile)
      this.audioInputTarget.files = dataTransfer.files

      this.stream.getTracks().forEach(track => track.stop())
    }
    this.recorder.start()
  }

  stop () {
    if (this.recorder && this.recorder.state !== "inactive") {
      this.startButtonTarget.disabled = false
      this.recorder.stop()
      this.stopButtonTarget.disabled = true
      }
    }

  async convertToWav(blob) {
    const audioContext = new AudioContext({ sampleRate: 16000 })
    const audioBuffer = await audioContext.decodeAudioData(await blob.arrayBuffer())
    audioContext.close()
    return new Blob([toWav(audioBuffer)], { type: "audio/wav" })
  }
}
