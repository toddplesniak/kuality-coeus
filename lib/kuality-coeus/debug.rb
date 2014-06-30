module DEBUG

  class << self

    def message(text='We got here!')
      puts text
    end

    def pause(seconds=30)
      sleep seconds
    end

  end

end