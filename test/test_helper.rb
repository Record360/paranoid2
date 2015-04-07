# -*- coding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "paranoid2"

require 'test/unit'

Test::Unit.at_start do
  Paranoid2.alive_value = DateTime.parse("9999-01-01")

  ActiveRecord::Base.establish_connection adapter: 'sqlite3', :database => ':memory:'
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define do
    create_table :parent_models do |t|
      t.datetime :deleted_at, :null => false
    end
    create_table :paranoid_models do |t|
      t.belongs_to :parent_model
      t.datetime :deleted_at, :null => false
    end
    create_table :featureful_models do |t|
      t.datetime :deleted_at, :null => false
      t.string :name
      t.string :phone
    end
    create_table :plain_models do |t|
      t.datetime :deleted_at
    end
    create_table :callback_models do |t|
      t.datetime :deleted_at, :null => false
    end
    create_table :related_models do |t|
      t.belongs_to :parent_model, :null => false
      t.datetime :deleted_at, :null => false
    end
    create_table :employers do |t|
      t.datetime :deleted_at, :null => false
    end
    create_table :employees do |t|
      t.datetime :deleted_at, :null => false
    end
    create_table :jobs do |t|
      t.belongs_to :employer, :null => false
      t.belongs_to :employee, :null => false
      t.datetime :deleted_at, :null => false
    end
  end

  class ParentModel < ActiveRecord::Base
    has_many :paranoid_models, dependent: :destroy
  end

  class PlainModel < ActiveRecord::Base
  end

  class ParanoidModel < ActiveRecord::Base
    paranoid
    belongs_to :parent_model
  end

  class FeaturefulModel < ActiveRecord::Base
    paranoid
    validates :name, presence: true, uniqueness: true
    validates :phone, uniqueness: {conditions: -> { paranoid_scope } }
    scope :find_last, -> name { where(name: name).last }
  end

  class CallbackModel < ActiveRecord::Base
    paranoid
    attr_accessor :callback_called
    before_destroy { self.callback_called = true }
  end

  class ParentModel < ActiveRecord::Base
    paranoid
    has_many :related_models
  end

  class RelatedModel < ActiveRecord::Base
    paranoid
    belongs_to :parent_model
  end

  class Employer < ActiveRecord::Base
    paranoid
    has_many :jobs
    has_many :employees, through: :jobs
  end

  class Employee < ActiveRecord::Base
    paranoid
    has_many :jobs
    has_many :employers, through: :jobs
  end

  class Job < ActiveRecord::Base
    paranoid
    belongs_to :employer
    belongs_to :employee
  end
end
