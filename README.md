# Paranoid2

[paranoia gem](https://github.com/radar/paranoia) ideas (and code) adapted for Rails >= 4.1

Rails 4 defines `ActiveRecord::Base#destroy!` so `Paranoid2` gem use `force: true` arg to force destroy.

## Installation

Add this line to your application's Gemfile:

    gem 'paranoid2'

And then execute:

    $ bundle

## Usage

### Migration

```ruby
create_table :users do |t|
  t.datetime :deleted_at, :null => false
end
```

### Model

```ruby
class User < ActiveRecord::Base
  paranoid
end
```

```ruby
user = User.create!
# >> INSERT INTO "users" ("deleted_at") VALUES (?)  [["deleted_at", "9999-01-01 00:00:00.000000"]]

User.count # => 1
# >> SELECT COUNT(*) FROM "users" WHERE "users"."deleted_at" = '9999-01-01 00:00:00.000000'

# will set deleted_at time
user.destroy! # => #<User id: 1, deleted_at: "2015-01-01 00:00:00">
# >> UPDATE "users" SET "deleted_at" = '2015-01-01 00:00:00.000000' WHERE "users"."id" = ?  [["id", 1]]

User.count # => 0
# >> SELECT COUNT(*) FROM "users" WHERE "users"."deleted_at" = '9999-01-01 00:00:00.000000'

User.with_deleted.count # => 1
# >> SELECT COUNT(*) FROM "users"

User.only_deleted.count # => 1
# >> SELECT COUNT(*) FROM "users" WHERE ("users"."deleted_at" != '9999-01-01 00:00:00.000000')

user.reload
# will destroy object for real
user.destroy!(force: true)
# DELETE FROM "users" WHERE "users"."id" = ?  [["id", 1]]

User.with_deleted.count # => 0
# >> SELECT COUNT(*) FROM "users"
```

### How to uniqueness validation

```ruby
class User < ActiveRecord::Base
  paranoid
  validates :name, uniqueness: {conditions: -> { paranoid_scope }}
end
```

### How to change deleted_at default value

```ruby
Paranoid2.configure do |config|
  config.alive_value = nil
end
```

But deleted_at is allow null. it is not recommended.
If normal use, does not need to know the initial value of deleted_at using.

### To restore record?

There is no way.
If the restoration is required, how to make the model is incorrect.
Rather than a logical delete, it is better to be implemented as a state.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
