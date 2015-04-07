$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "paranoid2"
Paranoid2.alive_value = DateTime.parse("9999-01-01")

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
user.deleted_at                 # => Fri, 01 Jan 9999 00:00:00 +0000
user.destroyed?                 # => false
User.count                      # => 1
User.with_deleted.count         # => 1
User.only_deleted.count         # => 0
user.destroy!                   # => #<User id: 1, deleted_at: "2015-04-07 09:55:19">
user.deleted_at                 # => 2015-04-07 09:55:19 UTC
user.destroyed?                 # => true
user.frozen?                    # => true
User.count                      # => 0
User.with_deleted.count         # => 1
User.only_deleted.count         # => 1
user.reload                     # clear frozen
user.destroy!(force: true)      # => #<User id: 1, deleted_at: "2015-04-07 18:55:19">
User.with_deleted.count         # => 0

# >>    (0.5ms)  CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "deleted_at" datetime NOT NULL) 
# >>    (0.1ms)  begin transaction
# >>   SQL (0.1ms)  INSERT INTO "users" ("deleted_at") VALUES (?)  [["deleted_at", "9999-01-01 00:00:00.000000"]]
# >>    (0.0ms)  commit transaction
# >>    (0.1ms)  SELECT COUNT(*) FROM "users" WHERE "users"."deleted_at" = '9999-01-01 00:00:00.000000'
# >>    (0.1ms)  SELECT COUNT(*) FROM "users"
# >>    (0.1ms)  SELECT COUNT(*) FROM "users" WHERE ("users"."deleted_at" != '9999-01-01 00:00:00.000000')
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  UPDATE "users" SET "deleted_at" = '2015-04-07 09:55:19.274507' WHERE "users"."id" = ?  [["id", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.1ms)  SELECT COUNT(*) FROM "users" WHERE "users"."deleted_at" = '9999-01-01 00:00:00.000000'
# >>    (0.0ms)  SELECT COUNT(*) FROM "users"
# >>    (0.1ms)  SELECT COUNT(*) FROM "users" WHERE ("users"."deleted_at" != '9999-01-01 00:00:00.000000')
# >>   User Load (0.1ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1  [["id", 1]]
# >>    (0.0ms)  begin transaction
# >>   SQL (0.1ms)  DELETE FROM "users" WHERE "users"."id" = ?  [["id", 1]]
# >>    (0.0ms)  commit transaction
# >>    (0.0ms)  SELECT COUNT(*) FROM "users"