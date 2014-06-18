class Lookups < BasePage

  tiny_buttons
  search_results_table

  def self.url_info(title, class_name)
    riceify = $context
    riceify.gsub!('c','r') if class_name[/^rice/] && $base_url[/kuali/]
    string = %|#{
    $base_url+$context
    }portal.do?channelTitle=#{
    title
    }&channelUrl=#{
    $base_url[/.*(?=\/$)/]+':'+$port+'/'+riceify
    }kr/lookup.do?methodToCall=start&businessObjectClassName=org.kuali.#{
    class_name
    }&docFormKey=88888888&returnLocation=#{
    $base_url[/.*(?=\/$)/]+':'+$port+'/'+$context
    }portal.do&hideReturnLink=true|
    puts string
    page_url string
  end

  # &includeCustomActionUrls=true
  #http://test.kc.kuali.org/kc-dly/portal.do?channelTitle=Person
  #&channelUrl=http://test.kc.kuali.org:80/kr-dly/kr/lookup.do?
  #methodToCall=start&businessObjectClassName=org.kuali.rice.kim.api.identity.Person
  #&docFormKey=88888888&returnLocation=http://test.kc.kuali.org:80/kc-dly/portal.do&hideReturnLink=true

  element(:last_name) { |b| b.frm.text_field(id: 'lastName') }
  element(:first_name) { |b| b.frm.text_field(id: 'firstName') }
  element(:full_name) { |b| b.frm.text_field(id: 'fullName') }
  element(:user_name) { |b| b.frm.text_field(id: 'userName') }
  element(:state) { |b| b.frm.select(id: 'state') }
  element(:create_button) { |b| b.frm.link(title: 'Create a new record') }
  action(:create_new) { |b| b.create_button.click; b.loading }
  alias_method :create, :create_new

end