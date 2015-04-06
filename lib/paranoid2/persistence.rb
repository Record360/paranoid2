module Paranoid2
  module Persistence
    extend ActiveSupport::Concern

    def destroy(opts = {})
      with_paranoid(opts) { super() }
    end

    def destroy!(opts = {})
      with_paranoid(opts) { super() }
    end

    def delete(opts = {})
      with_paranoid(opts) do
        touch(:deleted_at) if !deleted? && persisted?
        self.class.unscoped { super() } if paranoid_force
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

    module ClassMethods
      def paranoid? ; true ; end

      def destroy_all!(conditions = nil)
        with_paranoid(force: true) do
          destroy_all(conditions)
        end
      end
    end
  end
end
