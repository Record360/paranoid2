module Paranoid2
  concern :Scoping do
    included do
      default_scope { paranoid_scope }
    end

    class_methods do
      def paranoid_scope
        where(deleted_at: nil)
      end

      def only_deleted
        with_deleted.where.not(deleted_at: nil)
      end

      def with_deleted
        unscope(where: :deleted_at)
      end
    end
  end
end
