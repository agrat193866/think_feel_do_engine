def with_scope(locator)
  locator ? within(locator) { yield } : yield
end

# Save a snapshot of the current page including css and js, then open it in the
# browser as long as there is a server listening on port 3000.
def show_page
  save_page Rails.root.join("public", "capybara.html")
  `launchy http://localhost:3000/capybara.html`
end

# Select a rating.
def choose_rating(element_id, value)
  find("##{ element_id } .intensity_btn:nth-child(#{ value + 1 })").click
end

RSpec::Matchers.define :appear_before do |later_content|
  match do |earlier_content|
    expect(page.body.index(earlier_content)).to < page.body.index(later_content)
  end
end
