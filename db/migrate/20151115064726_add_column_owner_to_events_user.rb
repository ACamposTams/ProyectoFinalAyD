class AddColumnOwnerToEventsUser < ActiveRecord::Migration
  def change
  	add_column :events_users, :owner, :integer
  end
end
