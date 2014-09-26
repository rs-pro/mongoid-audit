## Mongoid::Audit

[![Gem Version](https://badge.fury.io/rb/mongoid-audit.png)](http://badge.fury.io/rb/mongoid-audit)
[![Dependency Status](https://www.versioneye.com/user/projects/53ea131f8b6db55f150000b7/badge.svg)](https://www.versioneye.com/user/projects/53ea131f8b6db55f150000b7)
[![License](http://img.shields.io/:license-mit-blue.svg)](https://github.com/rs-pro/mongoid-audit/blob/master/MIT-LICENSE.txt)

**MongoidAudit 1.0 is a complete rewrite and might break backwards compatibility**

Since 1.0.0, mongoid_audit is no longer a fork, but a wrapper of [mongoid-history](https://github.com/aq1018/mongoid-history), providing
out-of-the-box Userstamp, RailsAdmin integration and easier setup and configuration.

### Migrating from 0.x.x

1) delete the initializer (if you had default settings).

2) replace
```
include Mongoid::Audit::Trackable
track_history track_create: true, track_destroy: true
```
With:
```
include Trackable
```
3)  Database storage format for user / modifier in 1.0.0 was changed, since now [glebtv_mongoid_userstamp](https://github.com/glebtv/mongoid_userstamp) gem is used to store modifier. To migrate your data you should do something like:
  
    HistoryTracker.all.each{|ht| ht.rename(modifier_id: :updater_id)}

4) This gem includes storing modifier, but it is done via ```glebtv_mongoid_userstamp``` and not directly.

5) RailsAdmin auditing adapter is still fully supported.

## Installation

Add this line to your application's Gemfile:

    # must be after rails_admin, if you use it
    gem 'mongoid-audit', '~> 1.0.0'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongoid-audit

## Usage

Include ```Trackable``` in your models. That's it, you are done!

    include Trackable

## Advanced usage

Identical to Mongoid::History.
See https://github.com/aq1018/mongoid-history

    include Mongoid::History::Trackable
    include Mongoid::Userstamp
    track_history({
      track_create: true,
      track_destroy: true,
      track_update: true,
      modifier_field: :updater,
      except: ["created_at", "updated_at", "c_at", "u_at", "clicks", "impressions", "some_other_your_field"],
    })


### Rails Admin Integration

Add 

    config.audit_with :mongoid_audit

in ```config/initializers/rails_admin.rb```

## Credits

(c) 2013-2014 http://rocketscience.pro MIT License.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
