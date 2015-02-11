class DestroyInvalidMessages < ActiveRecord::Migration
  def change
    Message.all.select { |m| m.recipient.nil? }.map(&:destroy!)
  end
end
