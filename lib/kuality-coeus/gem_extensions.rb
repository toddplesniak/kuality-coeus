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

end