class CaseSummaryGenerator
  INSTRUCTIONS = <<~PROMPT.freeze
    Analiza la transcripción de una usuaria y responde exclusivamente con JSON válido.
    No agregues texto antes ni después del JSON.

    Devuelve exactamente esta estructura:
    {
      "summary": "Resumen objetivo de máximo 200 palabras.",
      "risk_level": "low | moderate | high | extreme"
    }

    Clasifica el riesgo según estos criterios:

    - low: control inicial, desautorización de la figura materna o incidentes
      aislados de violencia psicológica.
    - moderate: amenazas de sustracción de niñas, niños o adolescentes (NNA),
      violencia económica activa o litigiosidad incipiente.
    - high: violencia física previa, incumplimiento de órdenes previas,
      rechazo inducido del NNA o sustracción consumada por tiempo breve.
    - extreme: amenazas de muerte o feminicidio, uso o exhibición de armas,
      ocultamiento total de NNA o antecedentes de tentativa de feminicidio.

    Considera únicamente los hechos relatados en la transcripción.
    No inventes información ni hagas diagnósticos o conclusiones legales.
    Si no hay información suficiente para una categoría superior, usa el nivel
    más bajo que esté respaldado por el testimonio.
  PROMPT

  class Error < StandardError; end

  def initialize(case_record)
    @case_record = case_record
  end

  def call
    transcript = @case_record.opening_testimony&.transcript

    if transcript.blank?
      raise Error, "No hay una transcripción para resumir."
    end

    input = [
      "Testimonio revisado por la usuaria:",
      transcript
    ].join("\n")

    response = RubyLLM.chat(model: "gpt-4.1-mini")
                      .with_instructions(INSTRUCTIONS)
                      .ask(input)

    assessment = parse_assessment(response.content)
    summary = assessment.fetch("summary").to_s.strip
    risk_level = assessment.fetch("risk_level").to_s

    if summary.blank?
      raise Error, "No se pudo obtener un resumen del caso."
    end

    unless %w[low moderate high extreme].include?(risk_level)
      raise Error, "La IA devolvió un nivel de riesgo inválido."
    end

    @case_record.update!(summary: summary, risk_level: risk_level)

    summary
  end

  private

  def parse_assessment(content)
    assessment = JSON.parse(content.to_s)

    unless assessment.is_a?(Hash)
      raise Error, "La IA devolvió una evaluación inválida."
    end

    unless assessment.key?("summary") && assessment.key?("risk_level")
      raise Error, "La IA devolvió una evaluación incompleta."
    end

    assessment
  rescue JSON::ParserError
    raise Error, "La IA no devolvió una evaluación válida."
  end
end
