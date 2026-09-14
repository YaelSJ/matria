class CaseSummaryJob < ApplicationJob
  queue_as :default
  self.enqueue_after_transaction_commit = true

  discard_on ActiveRecord::RecordNotFound

  def perform(case_id)
    case_record = Case.find(case_id)
    CaseSummaryGenerator.new(case_record).call
  end
end
