require "test_helper"

class CaseTest < ActiveSupport::TestCase
  test "is not ready without the opening testimony transcript" do
    case_record = build_case
    case_record.case_files.create!(title: "Testimonio", state: "CDMX", file_type: :opening_testimony)

    assert_not case_record.ready_for_submission?
    assert_raises(ActiveRecord::RecordInvalid) do
      case_record.submit_for_review!(actor: case_record.user)
    end
  end

  test "submits a complete case for review" do
    case_record = build_case
    create_opening_testimony(case_record)

    case_record.submit_for_review!(actor: case_record.user)

    assert case_record.reload.pending_review?
    assert_not case_record.editable_by_user?
  end

  test "assigns a pending case without starting its review" do
    case_record = build_submitted_case
    representative = build_representative

    case_record.assign_to!(representative)

    assert case_record.reload.pending_review?
    assert_equal representative, case_record.representative
  end

  test "starts the review of an assigned case" do
    case_record = build_submitted_case
    representative = build_representative

    case_record.assign_to!(representative)
    case_record.start_review!(representative)

    assert case_record.reload.in_review?
  end

  test "approves a case in review" do
    case_record = build_case_in_review

    case_record.decide!(case_record.representative, :approved)

    assert case_record.reload.approved?
  end

  test "requires a comment when requesting changes" do
    case_record = build_case_in_review

    assert_raises(ActiveRecord::RecordInvalid) do
      case_record.decide!(case_record.representative, :changes_requested)
    end

    assert case_record.reload.in_review?
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

    user.case.tap do |case_record|
      case_record.update!(
        content: "Descripción del caso",
        consent: true,
        risk_level: :low
      )
    end
  end

  def build_submitted_case
    case_record = build_case
    create_opening_testimony(case_record)
    case_record.submit_for_review!(actor: case_record.user)
    case_record
  end

  def build_case_in_review
    case_record = build_submitted_case
    representative = build_representative
    case_record.assign_to!(representative)
    case_record.start_review!(representative)
    case_record
  end

  def build_representative
    User.create!(
      email: "representative-test-#{SecureRandom.hex(4)}@example.com",
      password: "Password123!",
      role: :representative,
      name: "Representante",
      last_name: "Prueba"
    )
  end

  def create_opening_testimony(case_record)
    case_record.case_files.create!(
      title: "Testimonio",
      state: "CDMX",
      file_type: :opening_testimony,
      transcript: "Mi testimonio inicial"
    )
  end
end
