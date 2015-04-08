$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require 'timecop'
require 'paranoid2'

Timecop.freeze(DateTime.parse("2015-01-01"))

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name, :null => false
    t.datetime :deleted_at, :null => false
  end
end

class User < ActiveRecord::Base
  paranoid
  # validates :name, :uniqueness => {:scope => :deleted_at}              # good
  validates :name, :uniqueness => {:conditions => -> { paranoid_scope }} # better
end

user = User.create!(name: "alice")
User.create!(name: "alice") rescue $! # => #<ActiveRecord::RecordInvalid: Validation failed: Name has already been taken>
user.destroy!
User.create!(name: "alice")
# >>    (0.0ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "deleted_at" datetime NOT NULL) 
# >>    (0.0ms)  begin transaction
# >>   User Exists (0.0ms)  SELECT  1 AS one FROM "users" WHERE "users"."name" = 'alice' AND "users"."deleted_at" = '9999-01-01 00:00:00.000000' LIMIT 1
# >>   SQL (0.0ms)  INSERT INTO "users" ("deleted_at", "name") VALUES (?, ?)  [["deleted_at", "9999-01-01 00:00:00.000000"], ["name", "alice"]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   User Exists (0.0ms)  SELECT  1 AS one FROM "users" WHERE "users"."name" = 'alice' AND "users"."deleted_at" = '9999-01-01 00:00:00.000000' LIMIT 1
# >>    (0.0ms)  rollback transaction
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  UPDATE "users" SET "deleted_at" = '2015-01-01 00:00:00.000000' WHERE "users"."id" = ?  [["id", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  begin transaction
# >>   User Exists (0.0ms)  SELECT  1 AS one FROM "users" WHERE "users"."name" = 'alice' AND "users"."deleted_at" = '9999-01-01 00:00:00.000000' LIMIT 1
# >>   SQL (0.0ms)  INSERT INTO "users" ("deleted_at", "name") VALUES (?, ?)  [["deleted_at", "9999-01-01 00:00:00.000000"], ["name", "alice"]]
# >>    (0.0ms)  commit transaction
