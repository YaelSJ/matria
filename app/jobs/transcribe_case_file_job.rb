class TranscribeCaseFileJob < ApplicationJob
  queue_as :default
  self.enqueue_after_transaction_commit = true

  discard_on ActiveRecord::RecordNotFound

  def perform(case_file_id)
    case_file = CaseFile.find(case_file_id)

    case_file.audio.open do |audio_wav|
      transcript = WhisperTranscriber.new(audio_wav.path).call
      case_file.update!(transcript: transcript)
    end

    Turbo::StreamsChannel.broadcast_replace_to(
      case_file,
      target: "transcription_review",
      partial: "cases/transcription_review",
      locals: {
        case_record: case_file.case,
        case_file: case_file,
        transcript: nil,
        consent: false
      }
    )
  end
end
