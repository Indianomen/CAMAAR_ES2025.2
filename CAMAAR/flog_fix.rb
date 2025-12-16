require 'flog'

module FlogFix
  def initialize(option = {})
    # Make sure we're working with an unfrozen hash
    unfrozen_options = option.dup
    super(unfrozen_options)
  end
end

Flog.prepend(FlogFix)