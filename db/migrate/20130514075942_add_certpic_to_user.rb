class AddCertpicToUser < ActiveRecord::Migration
  def change
    add_column :users, :certpic, :string
  end
end
