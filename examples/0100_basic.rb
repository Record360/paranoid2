$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require 'timecop'
require 'paranoid2'
require "active_support/time"

Time.zone = "Tokyo"
Timecop.freeze(Time.zone.parse("2015-01-01"))

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveSupport::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.datetime :deleted_at, :null => false
  end
end

class User < ActiveRecord::Base
  paranoid
end

user = User.create!
user.deleted_at                 # => Thu, 01 Jan 0000 00:00:00 +0000
user.destroyed?                 # => false
User.count                      # => 1
User.with_deleted.count         # => 1
User.only_deleted.count         # => 0
user.destroy!                   # => #<User id: 1, deleted_at: "2014-12-31 15:00:00">
user.deleted_at                 # => 2014-12-31 15:00:00 UTC
user.destroyed?                 # => true
user.frozen?                    # => true
User.count                      # => 0
User.with_deleted.count         # => 1
User.only_deleted.count         # => 1
user.reload                     # clear frozen
user.destroy!(force: true)      # => #<User id: 1, deleted_at: "2015-01-01 00:00:00">
User.with_deleted.count         # => 0

# >>    (0.0ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "deleted_at" datetime NOT NULL) 
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  INSERT INTO "users" ("deleted_at") VALUES (?)  [["deleted_at", "0000-01-01 00:00:00.000000"]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  SELECT COUNT(*) FROM "users" WHERE "users"."deleted_at" = '0000-01-01 00:00:00.000000'
# >>    (0.0ms)  SELECT COUNT(*) FROM "users"
# >>    (0.0ms)  SELECT COUNT(*) FROM "users" WHERE ("users"."deleted_at" != '0000-01-01 00:00:00.000000')
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  UPDATE "users" SET "deleted_at" = '2014-12-31 15:00:00.000000' WHERE "users"."id" = ?  [["id", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  SELECT COUNT(*) FROM "users" WHERE "users"."deleted_at" = '0000-01-01 00:00:00.000000'
# >>    (0.0ms)  SELECT COUNT(*) FROM "users"
# >>    (0.0ms)  SELECT COUNT(*) FROM "users" WHERE ("users"."deleted_at" != '0000-01-01 00:00:00.000000')
# >>   User Load (0.0ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1  [["id", 1]]
# >>    (0.0ms)  begin transaction
# >>   SQL (0.0ms)  DELETE FROM "users" WHERE "users"."id" = ?  [["id", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  SELECT COUNT(*) FROM "users"
