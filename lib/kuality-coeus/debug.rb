module DEBUG

  class << self

    def message(text='We got here!')
      puts text
    end

    def pause(seconds=30)
      puts "Pausing #{seconds} seconds..."
      sleep seconds
    end

    def do message='Performing debug code block...', &block
      puts message
      yield block
    end

    def inspect object
      puts
      puts "Inspection of #{object.class}..."
      puts object.pretty_inspect
    end

    def inspects *objects
      objects.each { |o| inspect o }
    end

    def snap(b)
      b.screenshot.save 'debug_capture.png'
    end

  end

  PageFactory.p_element(:define_elements) { |b|
    b.frm.text_fields.each { |t|
      puts 'element(:' + t.name.to_s.gsub(/([a-z])([A-Z])/ , '\1_\2').downcase + ') { |b| b.frm.text_field(name: \'' + t.name.to_s + '\') }'
    }

  }

end