class ChangeDefaultContactPreference < ActiveRecord::Migration
  def change
    change_column :participants, :contact_preference, :string, default: "email"
  end
end
