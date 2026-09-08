class AddDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :last_name, :string
    add_column :users, :user_contry, :string
    add_column :users, :city, :string
    add_column :users, :role, :string
    add_column :users, :phone_number, :string
    add_column :users, :age, :integer
    add_column :users, :state, :string
    add_column :users, :gender, :string
    add_column :users, :sex, :string
  end
end
