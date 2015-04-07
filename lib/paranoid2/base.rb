module Paranoid2
  concern :Base do
    class_methods do
      def paranoid?
        false
      end

      def paranoid
        include Persistence
        include Scoping
      end

      def with_paranoid(**options, &block)
        forced = options[:force] || paranoid_force
        previous, self.paranoid_force = paranoid_force, forced
        return yield
      ensure
        self.paranoid_force = previous
      end

      # FIXME
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

    def with_paranoid(*args, &block)
      self.class.with_paranoid(*args, &block)
    end
  end
end
