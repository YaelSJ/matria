class CaseSummaryGenerator
  def initialize(case_record)
    @case_record = case_record
  end

  def call
    @case_record.update!(summary: fallback_summary)
  end

  private

  def fallback_summary
    sections = [
      "Datos de la usuaria: #{user_details}",
      "Descripción del caso: #{@case_record.content.presence || 'No proporcionada'}",
      "Testimonio inicial: #{testimony.presence || 'No hay transcripción disponible'}",
      "Archivos adjuntos: #{files.presence || 'No hay archivos adicionales'}"
    ]

    sections.join("\n\n")
  end

  def testimony
    @case_record.opening_testimony&.transcript
  end

  def user_details
    user = @case_record.user
    [user.name, user.last_name, user.state, user.city, user.phone_number].compact_blank.join(", ")
  end

  def files
    @case_record.case_files.where.not(id: @case_record.opening_testimony&.id).pluck(:title).join(", ")
  end
end
