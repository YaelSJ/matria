# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
password = "123456"

create_user = lambda do |name, email, role, index|
  User.find_or_initialize_by(email: email).tap do |user|
    user.assign_attributes(
      name: name,
      last_name: "Demo",
      password: password,
      password_confirmation: password,
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

representatives = 1.upto(3).map do |index|
  create_user.call(
    "Representante #{index}",
    "representative#{index}@matria.com",
    :representative,
    index
  )
end

admin = create_user.call(
  "Admin 1",
  "admin1@matria.com",
  :admin,
  20
)

users = 1.upto(10).map do |index|
  user = create_user.call(
    "Usuaria #{index}",
    "user#{index}@matria.com",
    :user,
    index
  )

  status, representative = case index
                           when 1..3
                             [:draft, nil]
                           when 4..5
                             [:pending_review, nil]
                           when 6
                             [:pending_review, representatives[0]]
                           when 7
                             [:in_review, representatives[0]]
                           when 8
                             [:changes_requested, representatives[1]]
                           when 9
                             [:approved, representatives[1]]
                           when 10
                             [:closed, representatives[2]]
                           end

  case_record = Case.find_or_initialize_by(user: user)
  case_record.assign_attributes(
    representative: representative,
    status: status,
    consent: true,
    risk_level: %w[low medium high critical][(index - 1) % 4],
    content: "Caso de prueba de Usuaria #{index}.",
    summary: "Resumen del caso de Usuaria #{index}."
  )
  case_record.save!

  chat = Chat.find_or_initialize_by(
    user: user,
    title: "Chat de Usuaria #{index}"
  )
  chat.save!

  message = chat.messages.find_or_initialize_by(
    content: "Mensaje de prueba."
  )
  message.role = "user"
  message.save!

  case_file = case_record.case_files.find_or_initialize_by(
    title: "Documento de Usuaria #{index}"
  )
  case_file.assign_attributes(
    file_type: "opening_testimony",
    state: "Ciudad de México",
    document_number: "DOC-#{format("%03d", index)}",
    transcript: "Transcripción de prueba de Usuaria #{index}.",
    ai_summary: "Resumen generado para el caso de Usuaria #{index}."
  )
  case_file.save!

  user
end

puts "Seed completada:"
puts "- Usuarias: #{users.count}"
puts "- Casos en borrador: #{Case.where(status: :draft).count}"
puts "- Casos pendientes de revisión: #{Case.where(status: :pending_review).count}"
puts "- Casos en revisión: #{Case.where(status: :in_review).count}"
puts "- Casos con cambios solicitados: #{Case.where(status: :changes_requested).count}"
puts "- Casos aprobados: #{Case.where(status: :approved).count}"
puts "- Casos cerrados: #{Case.where(status: :closed).count}"
puts "- Representantes: #{representatives.count}"
puts "- Administradores: #{User.where(role: :admin).count}"
