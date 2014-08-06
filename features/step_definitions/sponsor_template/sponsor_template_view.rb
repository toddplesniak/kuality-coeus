And /^the Sponsor Template status should be '(.*)'$/ do |doc_status|
  on(SponsorTemplate).document_status == doc_status
end