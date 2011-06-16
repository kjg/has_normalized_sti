require 'rubygems'
require 'active_record'

require 'rspec'
require 'rspec/rails/extensions'
require 'rspec/rails/matchers'
require 'rspec/rails/adapters'
require 'rspec/rails/fixture_support'

$:.unshift File.dirname(__FILE__) + '/../lib'
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
load(File.dirname(__FILE__) + "/schema.rb")

class Person < ActiveRecord::Base
  has_normalized_sti
end

class Royal < Person
end

class Peasant < Person
end

class PersonType < ActiveRecord::Base
end
