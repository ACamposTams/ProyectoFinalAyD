class AddColumnStatusToEventsUsers < ActiveRecord::Migration
  def change
  	add_column :events_users, :status, :string
  end
end
