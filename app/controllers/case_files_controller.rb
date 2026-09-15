class CaseFilesController < ApplicationController

  def new
    @case = current_user.case
    @case_file = @case.case_files.build
  end

  def create
    @case = current_user.case
    @case_file = CaseFile.new(case_files_params)
    @case_file.case = @case
    @case_file.file_type = :opening_testimony

    if @case_file.save
      @case_file.audio.open do |audio_wav|
        audio_transcript = WhisperTranscriber.new(audio_wav.path).call
        @case_file.update!(transcript: audio_transcript)
      end
      redirect_to review_transcription_case_path(@case)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def case_files_params
    params.require(:case_file).permit(:audio)
  end
end
