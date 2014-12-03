# This migration comes from think_feel_do_engine (originally 20140815190945)
class AddPhqEditColumns < ActiveRecord::Migration
  def change
    add_column :phq_assessments, :q1_editor_id, :integer
    add_column :phq_assessments, :q2_editor_id, :integer
    add_column :phq_assessments, :q3_editor_id, :integer
    add_column :phq_assessments, :q4_editor_id, :integer
    add_column :phq_assessments, :q5_editor_id, :integer
    add_column :phq_assessments, :q6_editor_id, :integer
    add_column :phq_assessments, :q7_editor_id, :integer
    add_column :phq_assessments, :q8_editor_id, :integer
    add_column :phq_assessments, :q9_editor_id, :integer
  end
end
