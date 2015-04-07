module Paranoid2
  concern :Persistence do
    class_methods do
      def paranoid?
        true
      end

      def destroy_all!(conditions = nil)
        with_paranoid(force: true) do
          destroy_all(conditions)
        end
      end
    end

    def destroy(**options)
      with_paranoid(options) { super() }
    end

    def destroy!(**options)
      with_paranoid(options) { super() }
    end

    def delete(**options)
      with_paranoid(options) do
        if !deleted? && persisted?
          touch(:deleted_at)    # FIXME
        end
        if paranoid_force?
          self.class.unscoped { super() }
        end
      end
    end

    def destroyed?
      deleted_at != Paranoid2.alive_value
    end

    def persisted?
      !new_record?
    end

    alias deleted? destroyed?

    def destroy_row
      if paranoid_force?
        self.deleted_at = Time.now # FIXME
        super
      else
        delete
        1
      end
    end
  end
end
