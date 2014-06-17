module Watir
  module Container
    def frm
      frames = [
          iframe(id: 'iframeportlet'),
          iframe(id: /easyXDM_default\d+_provider/).iframe(id: 'iframeportlet'),
          iframe(id: /easyXDM_default\d+_provider/),
          self ]
      i = 0
      until frames[i].exists? do
        i=i+1
      end
      puts i.inspect
      frames[i]
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