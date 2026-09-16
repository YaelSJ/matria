require "whisper"

class WhisperTranscriber
  def initialize(audio_path)
    @audio_path = audio_path
  end

  def call
    context_params = Whisper::Context::Params.new(
      use_gpu: false,
      flash_attn: false
    )

    whisper = Whisper::Context.new("base", context_params)

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
