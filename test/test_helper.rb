$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "paranoid2"

require 'test/unit'

Paranoid2.alive_value = DateTime.parse("2050-01-01 00:00:00")

ActiveRecord::Base.establish_connection adapter: 'sqlite3', :database => ':memory:'
ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define do
  create_table :parent_models do |t|
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :paranoid_models do |t|
    t.belongs_to :parent_model
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :featureful_models do |t|
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
    t.string :name
    t.string :phone
  end
  create_table :plain_models do |t|
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :callback_models do |t|
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :related_models do |t|
    t.belongs_to :parent_model, :null => false
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :employers do |t|
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :employees do |t|
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
  create_table :jobs do |t|
    t.belongs_to :employer, :null => false
    t.belongs_to :employee, :null => false
    t.datetime :deleted_at, :null => false, :default => Paranoid2.alive_value
  end
end

require 'models'
