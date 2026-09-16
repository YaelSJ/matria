# Datos completamente ficticios para la demostración.
DEMO_PASSWORD = "123456".freeze
DEMO_AUDIO_PATH = Rails.root.join("audio_prueba30seg.wav").freeze

def demo_user(name:, email:, role:, index:)
  User.find_or_initialize_by(email: email).tap do |user|
    user.assign_attributes(
      name: name,
      last_name: "Demo",
      password: DEMO_PASSWORD,
      password_confirmation: DEMO_PASSWORD,
      role: role,
      user_country: "México",
      state: "Ciudad de México",
      city: "Ciudad de México",
      phone_number: "55100000#{format("%02d", index)}",
      birth_date: Date.new(1985 + (index % 12), (index % 12) + 1, (index % 25) + 1),
      gender: "Femenino",
      sex: "Mujer"
    )
    user.save!
  end
end

def demo_case(user:, status:, risk_level:, consent:, representative: nil)
  Case.find_or_initialize_by(user: user).tap do |case_record|
    case_record.assign_attributes(
      representative: representative,
      status: status,
      consent: consent,
      risk_level: risk_level,
      content: nil,
      summary: nil
    )
    case_record.save!
  end
end

def demo_opening_testimony(case_record:, user:, transcript:)
  case_file = case_record.case_files.find_or_initialize_by(file_type: :opening_testimony)
  case_file.assign_attributes(
    title: "Testimonio inicial de #{user.name}",
    document_number: "DEMO-#{format("%03d", user.id)}",
    state: user.state,
    transcript: transcript,
    ai_summary: "Resumen de demostración del testimonio de #{user.name}."
  )

  unless case_file.audio.attached?
    case_file.audio.attach(
      io: File.open(DEMO_AUDIO_PATH),
      filename: "testimonio-demo.wav",
      content_type: "audio/wav"
    )
  end

  case_file.save!
end

def demo_event(case_record:, user:, event_type:, from_status:, to_status:, comment: nil)
  CaseEvent.find_or_create_by!(
    case: case_record,
    user: user,
    event_type: event_type,
    from_status: from_status,
    to_status: to_status
  ) do |event|
    event.comment = comment
  end
end

representatives = 1.upto(3).map do |index|
  demo_user(
    name: "Representante #{index}",
    email: "representative#{index}@matria.com",
    role: :representative,
    index: index
  )
end

demo_user(name: "Admin 1", email: "admin1@matria.com", role: :admin, index: 20)

scenarios = [
  # user1: caso en borrador sin audio ni transcripción, listo para grabar.
  { status: :draft, risk_level: :low, consent: false, transcript: nil },
  # user2: transcripción disponible para revisar, editar y dar consentimiento.
  { status: :draft, risk_level: :medium, consent: false,
    transcript: "Este es un testimonio ficticio para revisar antes de otorgar el consentimiento." },
  { status: :pending_review, risk_level: :critical, consent: true,
    transcript: "Testimonio ficticio de un caso urgente, pendiente de asignación." },
  { status: :pending_review, risk_level: :high, consent: true, representative: representatives[0],
    transcript: "Testimonio ficticio de un caso pendiente y ya asignado." },
  { status: :in_review, risk_level: :medium, consent: true, representative: representatives[0],
    transcript: "Testimonio ficticio de un caso que está siendo revisado." },
  { status: :changes_requested, risk_level: :low, consent: true, representative: representatives[1],
    transcript: "Testimonio ficticio con información adicional pendiente." },
  { status: :approved, risk_level: :medium, consent: true, representative: representatives[1],
    transcript: "Testimonio ficticio de un caso aprobado." },
  { status: :closed, risk_level: :high, consent: true, representative: representatives[2],
    transcript: "Testimonio ficticio de un caso cerrado." }
].freeze

users = scenarios.each_with_index.map do |scenario, index|
  user_number = index + 1
  user = demo_user(
    name: "Usuaria #{user_number}",
    email: "user#{user_number}@matria.com",
    role: :user,
    index: user_number
  )

  case_record = demo_case(
    user: user,
    status: scenario[:status],
    risk_level: scenario[:risk_level],
    consent: scenario[:consent],
    representative: scenario[:representative]
  )

  if scenario[:transcript]
    demo_opening_testimony(
      case_record: case_record,
      user: user,
      transcript: scenario[:transcript]
    )
  end

  chat = Chat.find_or_create_by!(user: user, title: "Chat de #{user.name}")
  chat.messages.find_or_create_by!(content: "Mensaje ficticio para la demostración.") do |message|
    message.role = "user"
  end

  case scenario[:status]
  when :pending_review
    demo_event(case_record: case_record, user: user, event_type: "submitted",
               from_status: "draft", to_status: "pending_review")
    if scenario[:representative]
      demo_event(case_record: case_record, user: scenario[:representative], event_type: "assigned",
                 from_status: "pending_review", to_status: "pending_review")
    end
  when :in_review, :changes_requested, :approved, :closed
    representative = scenario.fetch(:representative)
    demo_event(case_record: case_record, user: user, event_type: "submitted",
               from_status: "draft", to_status: "pending_review")
    demo_event(case_record: case_record, user: representative, event_type: "assigned",
               from_status: "pending_review", to_status: "pending_review")
    demo_event(case_record: case_record, user: representative, event_type: "review_started",
               from_status: "pending_review", to_status: "in_review")

    if scenario[:status] == :changes_requested
      demo_event(case_record: case_record, user: representative, event_type: "changes_requested",
                 from_status: "in_review", to_status: "changes_requested",
                 comment: "Por favor, agrega información ficticia adicional para la demostración.")
    elsif scenario[:status] == :approved
      demo_event(case_record: case_record, user: representative, event_type: "approved",
                 from_status: "in_review", to_status: "approved")
    elsif scenario[:status] == :closed
      demo_event(case_record: case_record, user: representative, event_type: "closed",
                 from_status: "in_review", to_status: "closed",
                 comment: "Cierre ficticio para la demostración.")
    end
  end

  user
end

puts "Seeds de Demo Day completados:"
puts "- Usuarias: #{users.count}"
puts "- Representantes: #{representatives.count}"
puts "- Administradoras: #{User.where(role: :admin).count}"
puts "- Grabación de testimonio: user1@matria.com / #{DEMO_PASSWORD}"
puts "- Revisión de transcripción: user2@matria.com / #{DEMO_PASSWORD}"
