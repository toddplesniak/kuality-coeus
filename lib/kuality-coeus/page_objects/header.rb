class Header < BasePage
  expected_element :doc_search_link

  # Header links
  action(:researcher) { |b|
    5.times {
      b.researcher_link.click
      sleep 1
      break if b.researcher_link.parent.div.visible?
    }
  }
  action(:kns_portal) { |b| b.link(text: 'SYSTEM ADMIN PORTAL').click }
  alias_method :system_admin_portal, :kns_portal

  element(:researcher_link) { |b| b.link(text: 'RESEARCHER') }
  element(:doc_search_link) { |b| b.link(text: 'Doc Search') }

  action(:doc_search) { |b|
    if b.link(title: 'Document Search').present?
      b.link(title: 'Document Search').click
    else
      b.doc_search_link.click
    end
  }

  action(:log_out) { |b| b.link(text: /User:/).click; b.link(text: 'Logout').click }

  action(:action_list) { |b| b.link(text: 'Action List').click }

end