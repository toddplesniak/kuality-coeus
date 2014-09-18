class CentralAdmin < BasePage

  page_url "#{$base_url+$context}portal.do?selectedTab=portalCentralAdminBody"

  green_buttons create_award: 'Award', create_proposal_log: 'Proposal Log',
                create_institutional_proposal: 'Institutional Proposal', create_subaward: 'Subawards'

  action(:create_irb_committee) { |b| b.td(text: 'IRB Committee').parent.link(title: 'Create Committee').click }
  action(:create_iacuc_committee) { |b| b.td(text: 'IACUC Committee').parent.link(title: 'Create Committee').click }

end