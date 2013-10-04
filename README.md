Mongoid::Audit
==============

Mongoid Audit is a fork of mongoid-history https://github.com/aq1018/mongoid-history

Fork differences:
 * Rails 4 support
 * Built in rails_admin auditing support
 * Properly setting user (modifier) all the time

In case of problems, you can try mongoid-history, which didn't work properly for us.

[![Build Status](https://secure.travis-ci.org/rs-pro/mongoid-audit.png?branch=master)](http://travis-ci.org/rs-pro/mongoid-audit)
[![Dependency Status](https://gemnasium.com/rs-pro/mongoid-audit.png)](https://gemnasium.com/rs-pro/mongoid-audit)
[![Coverage Status](https://coveralls.io/repos/rs-pro/mongoid-audit/badge.png?branch=master)](https://coveralls.io/r/rs-pro/mongoid-audit?branch=master)
[![Gem Version](https://badge.fury.io/rb/mongoid-audit.png)](http://badge.fury.io/rb/mongoid-audit)

Mongoid-audit tracks historical changes for any document, including embedded ones. It achieves this by storing all history tracks in a single collection that you define. Embedded documents are referenced by storing an association path, which is an array of `document_name` and `document_id` fields starting from the top most parent document and down to the embedded document that should track history.

This gem also implements multi-user undo, which allows users to undo any history change in any order. Undoing a document also creates a new history track. This is great for auditing and preventing vandalism, but is probably not suitable for use cases such as a wiki.

Installation
____________

Add this line to your application's Gemfile:

    # must be after rails_admin, if you use it
    gem 'mongoid-audit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid-audit

Usage
-----

**Rails Admin Integration**

    # note that instead of a user class, you pass in history tracker table name as second argument
    config.audit_with :mongoid_audit, 'HistoryTracker'


**Create a history tracker**

Create a new class to track histories. All histories are stored in this tracker. The name of the class can be anything you like. The only requirement is that it includes `Mongoid::Audit::Tracker`

```ruby
# app/models/history_tracker.rb
class HistoryTracker
  include Mongoid::Audit::Tracker
end
```

**Set tracker class name**

Manually set the tracker class name to make sure your tracker can be found and loaded properly. You can skip this step if you manually require your tracker before using any trackables.

The following example sets the tracker class name using a Rails initializer.

```ruby
# config/initializers/mongoid-audit.rb
# initializer for mongoid-audit
# assuming HistoryTracker is your tracker class
Mongoid::Audit.tracker_class_name = :history_tracker
```

**Set `#current_user` method name**

You can set the name of the method that returns currently logged in user if you don't want to set `modifier` explicitly on every update.

The following example sets the `current_user_method` using a Rails initializer

```ruby
# config/initializers/mongoid-audit.rb
# initializer for mongoid-audit
# assuming you're using devise/authlogic
Mongoid::Audit.current_user_method = :current_user
```

**IMPORTANT**
for this to work in development environment, add
```ruby
require_dependency 'history_tracker.rb' if Rails.env == "development"
```
to the initializer so controller filter would be installed


When `current_user_method` is set, mongoid-audit will invoke this method on each update and set its result as the instance modifier.

```ruby
# assume that current_user return #<User _id: 1>
post = Post.first
post.update_attributes(:title => 'New title')

post.history_tracks.last.modifier #=> #<User _id: 1>
```

**Create trackable classes and objects**

```ruby
class Post
  include Mongoid::Document
  include Mongoid::Timestamps

  # history tracking all Post documents
  # note: tracking will not work until #track_history is invoked
  include Mongoid::Audit::Trackable

  field           :title
  field           :body
  field           :rating
  embeds_many     :comments

  # telling Mongoid::Audit how you want to track changes
  track_history   :on => [:title, :body],       # track title and body fields only, default is :all
                  :modifier_field => :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  false,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  false     # track document destruction, default is false
end

class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  # declare that we want to track comments
  include Mongoid::Audit::Trackable

  field             :title
  field             :body
  embedded_in       :post, :inverse_of => :comments

  # track title and body for all comments, scope it to post (the parent)
  # also track creation and destruction
  track_history     :on => [:title, :body], :scope => :post, :track_create => true, :track_destroy => true
end

# the modifier class
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field             :name
end

user = User.create(:name => "Aaron")
post = Post.create(:title => "Test", :body => "Post", :modifier => user)
comment = post.comments.create(:title => "test", :body => "comment", :modifier => user)
comment.history_tracks.count # should be 1

comment.update_attributes(:title => "Test 2")
comment.history_tracks.count # should be 2

track = comment.history_tracks.last

track.undo! user # comment title should be "Test"

track.redo! user # comment title should be "Test 2"

# undo last change
comment.undo! user

# undo versions 1 - 4
comment.undo! user, :from => 4, :to => 1

# undo last 3 versions
comment.undo! user, :last => 3

# redo versions 1 - 4
comment.redo! user, :from => 1, :to => 4

# redo last 3 versions
comment.redo! user, :last => 3

# delete post
post.destroy

# undelete post
post.undo! user

# disable tracking for comments within a block
Comment.disable_tracking do
  comment.update_attributes(:title => "Test 3")
end
```
For more examples, check out [spec/integration/integration_spec.rb](https://github.com/aq1018/mongoid-history/blob/master/spec/integration/integration_spec.rb).

## Credits

This gem is based on https://github.com/aq1018/mongoid-history

The original gem didn't work correctly for us, when not setting modifier manually, so we rewrote it a bit.
Seems to work fully now, including manually setting modifier

Mongoid-history Copyright (c) 2011-2012 Aaron Qian. MIT License. See [LICENSE.txt](https://github.com/aq1018/mongoid-history/blob/master/LICENSE.txt) for further details.

Mongoid-audit Copyright (c) 2013 http://rocketscience.pro MIT License.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
