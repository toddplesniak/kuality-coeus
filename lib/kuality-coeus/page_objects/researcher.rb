class Researcher < BasePage

  expected_element :doc_srch_button

  page_url "#{$base_url+$context}portal.do?selectedTab=portalResearcherBody"

  links 'Create Proposal', 'All My Proposals', 'Search Proposals', 'Create IRB Protocol', 'Search Proposal Log',
        'Search Institutional Proposals', 'Create IACUC Protocol'

  element(:error_table) { |b| b.frm.table(class: 'container2') }

  action(:action_list) { |b| b.frm.link(title: 'Action List').click }
  element(:doc_srch_button) { |b| b.frm.link(title: 'Document Search') }
  action(:doc_search) { |b| b.doc_srch_button.click }

end