require "whisper"

class WhisperTranscriber
  def initialize(audio_path)
    @audio_path = audio_path
  end

  def call
    whisper = Whisper::Context.new("small")

    params = Whisper::Params.new(
      language: "es",
      print_timestamps: false
    )

    transcript = ""

    whisper.transcribe(@audio_path, params) do |text|
      transcript << text
    end

    transcript.dup.force_encoding(Encoding::UTF_8).scrub("").squish
  end
end
