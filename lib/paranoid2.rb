require 'active_support/core_ext/module/concerning'
require 'active_record'
require 'active_support/configurable'

require 'paranoid2/version'
require 'paranoid2/persistence'
require 'paranoid2/scoping'
require 'paranoid2/base'

module Paranoid2
  include ActiveSupport::Configurable
  config_accessor(:alive_value) { DateTime.parse("9999-01-01") }
end

ActiveSupport.on_load(:active_record) { include Paranoid2::Base }
