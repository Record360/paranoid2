require 'paranoid2/version'

require 'active_support/core_ext/module/concerning'
require 'active_record'

require 'paranoid2/persistence'
require 'paranoid2/scoping'
require 'paranoid2/base'

ActiveSupport.on_load(:active_record) { include Paranoid2::Base }
