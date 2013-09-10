class AddCertAuthToUser < ActiveRecord::Migration
  def change
    add_column :users, :cert_auth, :integer
  end
end
