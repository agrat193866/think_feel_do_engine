require "rspec/expectations"

RSpec::Matchers.define :have_the_table do |expected|
  match do |actual|
    expected[:cells].all? do |cell_content|
      actual.has_xpath? "//table[@id='#{ expected[:id] }']/tbody/tr/td[contains(., '#{ cell_content }')]"
    end
  end

  failure_message do |actual|
    "expected that\n#{ actual.find(:xpath, "//table[@id='#{ expected[:id] }']").text }\nwould contain\n|| #{ expected[:cells].join(" | ") } ||"
  end
end
