module Paranoid2
  concern :Scoping do
    included do
      # Affect to default value of deleted_at when create.
      default_scope { paranoid_scope }

      scope :paranoid_scope, -> { where(deleted_at: Paranoid2.alive_value) }
      scope :only_deleted,   -> { with_deleted.where.not(deleted_at: Paranoid2.alive_value) }
      scope :with_deleted,   -> { unscope(where: :deleted_at) }
    end
  end
end
