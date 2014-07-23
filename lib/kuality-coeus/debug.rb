module DEBUG

  class << self

    def message(text='We got here!')
      puts text
    end

    def pause(seconds=30)
      sleep seconds
    end

  end

  PageFactory.p_element(:define_elements) { |b|
    b.frm.text_fields.each { |t|
      puts 'element(:' + t.name.to_s.gsub(/([a-z])([A-Z])/ , '\1_\2').downcase + ') { |b| b.frm.text_field(name: \'' + t.name.to_s + '\') }'
    }

  }

end