# Danger ShipHawk Plugin
A [Danger](https://github.com/danger/danger) plugin for [Rubocop](https://github.com/bbatsov/rubocop) that prints warnings.

## Installation:
Add this line to your Gemfile:

```rb
gem 'danger-shiphawk-plugin'
```

## Usage:
Inside `Dangerfile` specifying next line

```ruby
rubocop.checkup
```

#### Options:
This method accepts configuration hash.
The following keys are supported:

* `files: 'all'` ('all' | 'diff') Files to lint
* `config: nil` Path to the config `.rubocop.yml` file
* `limit_of_warnings: 10` (Number) Count of offenses that should be displayed
* `autofix_count: 30` (Number) Rubocop auto-fix will appear when errors count less then this number

## License:
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## How to: Build
Upgrade version in `lib/version.rb`
Then create new version of a gem:

```
gem build danger-shiphawk-plugin.gemspec
```
