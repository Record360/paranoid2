module Paranoid2
  module Persistence
    extend ActiveSupport::Concern

    def destroy(options = {})
      with_paranoid(options) { super() }
    end

    def destroy!(options = {})
      with_paranoid(options) { super() }
    end

    def delete(options = {})
      with_paranoid(options) do
        if !deleted? && persisted?
          touch(:deleted_at)
        end
        if paranoid_force
          self.class.unscoped { super() }
        end
      end
    end

    def destroyed?
      !deleted_at.nil?
    end

    def persisted?
      !new_record?
    end

    alias :deleted? :destroyed?

    def destroy_row
      if paranoid_force
        self.deleted_at = Time.now
        super
      else
        delete
        1
      end
    end

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
  end
end
