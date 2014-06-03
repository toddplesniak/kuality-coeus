class Researcher < BasePage

  page_url "#{$base_url+$context}portal.do?selectedTab=portalResearcherBody"

  links 'Create Proposal', 'All My Proposals', 'Search Proposals', 'Create IRB Protocol', 'Search Proposal Log',
        'Search Institutional Proposals'

  element(:error_table) { |b| b.frm.table(class: 'container2') }

  action(:action_list) { |b| b.frm.link(title: 'Action List').click }
  action(:doc_search) { |b| b.frm.link(title: 'Document Search').click }

end