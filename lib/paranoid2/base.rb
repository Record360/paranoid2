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

      def with_paranoid(force: false, &block)
        paranoid_stack.push(force || paranoid_force?)
        yield
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

    def with_paranoid(...)
      self.class.with_paranoid(...)
    end
  end
end
