require "tmpdir"

class AudioToWavConverter
  def initialize(audio_path)
    @audio_path = audio_path
  end

  def call
    Dir.mktmpdir do |directory|
      wav_path = File.join(directory, "audio.wav")
      success = system(
        "ffmpeg", "-y",
        "-i", @audio_path,
        "-ar", "16000",
        "-ac", "1",
        "-c:a", "pcm_s16le",
        wav_path.to_s
      )

      raise "No se pudo convertir el audio a WAV" unless success

      yield wav_path
    end
  end
end
