module Paranoid2
  concern :Scoping do
    included do
      # Affect to default value of deleted_at when create.
      default_scope { paranoid_scope }
    end

    class_methods do
      def paranoid_scope
        where(deleted_at: Paranoid2.alive_value)
      end

      def only_deleted
        with_deleted.where.not(deleted_at: Paranoid2.alive_value)
      end

      def with_deleted
        unscope(where: :deleted_at)
      end
    end
  end
end
