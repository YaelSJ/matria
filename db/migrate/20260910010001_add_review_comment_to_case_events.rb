class AddReviewCommentToCaseEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :case_events, :to_status, false
  end
end
