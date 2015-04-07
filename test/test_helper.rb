$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "paranoid2"

require 'test/unit'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', :database => ':memory:'
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :parent_models do |t|
    t.datetime :deleted_at
  end
  create_table :paranoid_models do |t|
    t.belongs_to :parent_model
    t.datetime :deleted_at
  end
  create_table :featureful_models do |t|
    t.datetime :deleted_at
    t.string :name
    t.string :phone
  end
  create_table :plain_models do |t|
    t.datetime :deleted_at
  end
  create_table :callback_models do |t|
    t.datetime :deleted_at
  end
  create_table :related_models do |t|
    t.belongs_to :parent_model, :null => false
    t.datetime :deleted_at
  end
  create_table :employers do |t|
    t.datetime :deleted_at
  end
  create_table :employees do |t|
    t.datetime :deleted_at
  end
  create_table :jobs do |t|
    t.belongs_to :employer, :null => false
    t.belongs_to :employee, :null => false
    t.datetime :deleted_at
  end
end

require 'models'
