class AddIsAdminToAllCurrentUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.is_admin = true
      user.save!
    end
  end

  def down
    User.all.each do |user|
      user.is_admin = false
      user.save!
    end
  end
end