class Login < BasePage

  # page_url "#{$base_url+$context}kr-login/login?viewId=DummyLoginView&returnLocation=%2Fkc-krad%2FlandingPage"
  page_url "#{$base_url+$context}backdoorlogin.do"
  # page_url "#{$base_url+$context}login?service=http%3A%2F%2Ftest.kc.kuali.org%3A80%2Fkc-dly%2Fportal.do"

# DEBUG.message 'Hot Fix non 6.0'
  element(:username) { |b| b.text_field(name: 'username') }
  action(:login) { |b| b.button(name: 'submit').click }

  # element(:username) { |b| b.text_field(name: /login_user/) }
  element(:login_button) { |b| b.button(id: 'Rice-LoginButton') }
  # action(:login) { |b| b.login_button.click }
end

class CASLogin < BasePage

  page_url "#{$base_url+$cas_context}login"
  element(:username) { |b| b.text_field(name: 'username') }
  element(:login_button) { |b| b.button(name: 'submit') }

  action(:login) { |b| b.login_button.click }

end