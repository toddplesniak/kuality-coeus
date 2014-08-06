When /^the Modify Sponsor Template user submits a new Award Sponsor Template without a Sponsor Term$/ do
  steps %{ * I log in with the Modify Sponsor Template user }
  @sponsor_template = create SponsorTemplateObject, sponsor_terms: nil
end

When /create a Sponsor Template$/ do
  @sponsor_template = create SponsorTemplateObject
end