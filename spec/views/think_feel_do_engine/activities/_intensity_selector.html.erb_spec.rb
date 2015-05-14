require "rails_helper"

RSpec.describe "think_feel_do_engine/activities/_intensity_selector",
               type: :view do
  fixtures :all

  def stub_form
    instance_double("ActionView::Helpers::Formbuilder", label: nil)
  end

  it "includes an empty option for include_blank: true" do
    render partial: "think_feel_do_engine/activities/intensity_selector",
           locals: {
             include_blank: true,
             form: stub_form,
             name: "name",
             label: "label"
           }

    expect(rendered).to match(/<option><\/option>/)
  end

  it "excludes an empty option by default" do
    render partial: "think_feel_do_engine/activities/intensity_selector",
           locals: {
             form: stub_form,
             name: "name",
             label: "label"
           }

    expect(rendered).not_to match(/<option><\/option>/)
  end
end
