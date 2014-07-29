module Transforms

  YES_NO = { set: 'Yes', clear: 'No' }

  ON_OFF = { set: 'on', clear: 'off' }

  CREDIT_SPLITS = { recognition: 'Recognition', responsibility: 'Responsibility', space: 'Space', financial: 'Financial' }

  CAN = { 'can ' => :should, 'can\'t ' => :should_not }

  CHECK = { set: true, clear: false }

end