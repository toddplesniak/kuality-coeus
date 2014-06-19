module Watir
  module Container
    def frm
      if div(id: 'embedded').exists?
        iframe(id: /easyXDM_default\d+_provider/).iframe(id: 'iframeportlet')
      else
        self
      end
    end
  end

  # Because of the unique way we
  # set up radio buttons in Coeus,
  # we can use this method in our
  # radio button definitions.
  class Radio
    def fit answer
      set unless answer==nil
    end
  end
end