require 'paranoid2/version'

require 'active_support/core_ext/module/concerning'
require 'active_record'

require 'paranoid2/persistence'
require 'paranoid2/scoping'

module Paranoid2
  extend ActiveSupport::Concern

  class_methods do
    def paranoid?
      false
    end

    def paranoid
      include Persistence
      include Scoping
    end

    alias acts_as_paranoid paranoid

    def with_paranoid(options = {})
      forced = options[:force] || paranoid_force
      previous, self.paranoid_force = paranoid_force, forced
      return yield
    ensure
      self.paranoid_force = previous
    end

    def paranoid_force=(value)
      Thread.current['paranoid_force'] = value
    end

    def paranoid_force
      Thread.current['paranoid_force']
    end
  end

  def paranoid?
    self.class.paranoid?
  end

  def paranoid_force
    self.class.paranoid_force
  end

  def with_paranoid(value, &block)
    self.class.with_paranoid value, &block
  end
end

ActiveSupport.on_load(:active_record) { include Paranoid2 }
