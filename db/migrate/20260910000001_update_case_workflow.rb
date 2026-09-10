class UpdateCaseWorkflow < ActiveRecord::Migration[8.1]
  def change
    change_column_default :cases, :status, from: "pending", to: "draft"
    add_column :case_files, :kind, :string, null: false, default: "document"

    reversible do |direction|
      direction.up do
        execute <<~SQL.squish
          UPDATE cases
          SET status = 'draft'
          WHERE status IS NULL OR status = 'pending'
        SQL

        execute <<~SQL.squish
          UPDATE case_files
          SET kind = 'opening_testimony'
          WHERE id IN (
            SELECT DISTINCT ON (case_id) id
            FROM case_files
            WHERE transcript IS NOT NULL AND transcript <> ''
            ORDER BY case_id, created_at, id
          )
        SQL
      end
    end
  end
end
