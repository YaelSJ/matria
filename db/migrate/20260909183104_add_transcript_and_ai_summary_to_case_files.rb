class AddTranscriptAndAiSummaryToCaseFiles < ActiveRecord::Migration[8.1]
  def change
    add_column :case_files, :transcript, :text
    add_column :case_files, :ai_summary, :text
  end
end
