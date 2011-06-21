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

class PersonType < ActiveRecord::Base
end

class SpecialPersonType < ActiveRecord::Base
  set_table_name :person_types
end

class Person < ActiveRecord::Base
  has_normalized_sti
end

class SpecialPerson < ActiveRecord::Base
  set_table_name :people
  has_normalized_sti :type_class_name => 'SpecialPersonType', :type_column => 'special_person_type', :foreign_key => 'special_type_id'
end

class Royal < Person
end

class Peasant < SpecialPerson
end

class ReallySpecialPerson < ActiveRecord::Base
  set_table_name :people
  has_normalized_sti :type_class_name => :special_person_type, :type_column => :special_person_type, :foreign_key => :special_type_id
end

class Farmer < ReallySpecialPerson
end
