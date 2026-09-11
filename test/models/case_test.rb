require "test_helper"

class CaseTest < ActiveSupport::TestCase
  test "is not ready without the opening testimony transcript" do
    case_record = build_case
    case_record.case_files.create!(title: "Testimonio", state: "CDMX", file_type: :opening_testimony)

    assert_not case_record.ready_for_submission?
    assert_raises(ActiveRecord::RecordInvalid) { case_record.submit_for_review! }
  end

  test "submits a complete case for review" do
    case_record = build_case
    case_record.case_files.create!(
      title: "Testimonio",
      state: "CDMX",
      file_type: :opening_testimony,
      transcript: "Mi testimonio inicial"
    )

    case_record.submit_for_review!

    assert case_record.in_review?
    assert_not case_record.editable_by_user?
  end

  private

  def build_case
    user = User.create!(
      email: "case-test-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: :user,
      name: "Usuaria",
      last_name: "Prueba"
    )

    Case.create!(
      user: user,
      content: "Descripción del caso",
      consent: true,
      risk_level: "low"
    )
  end
end
