require 'active_support/core_ext/module/concerning'
require 'active_record'
require 'active_support/configurable'

require 'paranoid2/version'
require 'paranoid2/persistence'
require 'paranoid2/scoping'
require 'paranoid2/base'

module Paranoid2
  include ActiveSupport::Configurable
  config_accessor(:alive_value) { DateTime.parse("0000-01-01") } # It is not on purpose through the Time.zone
end

ActiveSupport.on_load(:active_record) { include Paranoid2::Base }
