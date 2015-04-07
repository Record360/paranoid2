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
        paranoid_stack.push(options[:force] || paranoid_stack.last)
        return yield
      ensure
        paranoid_stack.pop
      end

      def paranoid_force?
        paranoid_stack.last
      end

      private

      def paranoid_stack
        Thread.current['paranoid_stack'] ||= []
      end
    end

    def paranoid?
      self.class.paranoid?
    end

    def paranoid_force?
      self.class.paranoid_force?
    end

    def with_paranoid(*args, &block)
      self.class.with_paranoid(*args, &block)
    end
  end
end
