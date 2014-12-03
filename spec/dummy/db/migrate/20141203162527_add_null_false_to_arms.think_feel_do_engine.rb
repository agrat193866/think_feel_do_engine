# This migration comes from think_feel_do_engine (originally 20141125194600)
class AddNullFalseToArms < ActiveRecord::Migration
  def change
    change_column_null :arms, :title, false
    change_column_null :arms, :is_social, false
  end
end