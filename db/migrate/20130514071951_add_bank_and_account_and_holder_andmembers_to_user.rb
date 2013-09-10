class AddBankAndAccountAndHolderAndmembersToUser < ActiveRecord::Migration
  def change
    add_column :users, :bank, :string
    add_column :users, :account, :string
    add_column :users, :holder, :string
    add_column :users, :members, :string
  end
end
