require 'bundler'
Bundler.require

require 'minitest/autorun'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', :database => ':memory:'

[ 'CREATE TABLE parent_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)',
  'CREATE TABLE paranoid_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER, deleted_at DATETIME)',
  'CREATE TABLE featureful_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME, name VARCHAR(32), phone VARCHAR(20))',
  'CREATE TABLE plain_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)',
  'CREATE TABLE callback_models (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)',
  'CREATE TABLE related_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER NOT NULL, deleted_at DATETIME)',
  'CREATE TABLE employers (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)',
  'CREATE TABLE employees (id INTEGER NOT NULL PRIMARY KEY, deleted_at DATETIME)',
  'CREATE TABLE jobs (id INTEGER NOT NULL PRIMARY KEY, employer_id INTEGER NOT NULL, employee_id INTEGER NOT NULL, deleted_at DATETIME)'
].each {|script| ActiveRecord::Base.connection.execute script }

require_relative 'spec_models'
