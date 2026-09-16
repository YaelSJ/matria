import { Controller } from "@hotwired/stimulus"
import toWav from "audiobuffer-to-wav"

// Connects to data-controller="audio-recorder"
export default class extends Controller {
  static targets = ["audioInput", "timer", "preview", "submit"]

  async connect() {
    this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
  }

  disconnect() {
    this.stream?.getTracks().forEach(track => track.stop())
  }

  start() {
    if (!this.stream || this.recorder?.state === "recording") return

    this.chunks = []
    this.recorder = new MediaRecorder(this.stream)
    this.recorder.ondataavailable = (event) => this.chunks.push(event.data)
    this.recorder.onstop = () => this.save()
    this.recorder.start()

    this.startedAt = Date.now()
    this.timer = setInterval(() => this.showElapsedTime(), 250)
    this.element.classList.add("recording")
  }

  stop() {
    if (this.recorder?.state !== "recording") return

    this.recorder.stop()
    clearInterval(this.timer)
    this.element.classList.remove("recording")
  }

  showElapsedTime() {
    const seconds = Math.floor((Date.now() - this.startedAt) / 1000)
    this.timerTarget.textContent = `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, "0")}`
  }

  async save() {
    const audioBlob = new Blob(this.chunks, { type: this.recorder.mimeType })
    const wavBlob = await this.convertToWav(audioBlob)

    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(new File([wavBlob], "grabacion.wav", { type: "audio/wav" }))
    this.audioInputTarget.files = dataTransfer.files

    this.previewTarget.src = URL.createObjectURL(wavBlob)
    this.previewTarget.classList.remove("d-none")
    this.submitTarget.disabled = false
  }

  async convertToWav(blob) {
    const audioContext = new AudioContext({ sampleRate: 16000 })
    const audioBuffer = await audioContext.decodeAudioData(await blob.arrayBuffer())
    audioContext.close()
    return new Blob([toWav(audioBuffer)], { type: "audio/wav" })
  }
}
