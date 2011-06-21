require File.expand_path('../spec_helper', __FILE__)

class TestPerson < ActiveRecord::Base
  set_table_name "people"
  set_inheritance_column :full_name
end

control_insert_start = Time.now
10000.times do |i|
  TestPerson.create!
end
control_insert_end = Time.now
puts "Baseline insert #{control_insert_end - control_insert_start}"

control_select_start = Time.now
TestPerson.all
control_select_end = Time.now
puts "Baseline select #{control_select_end - control_select_start}"

TestPerson.delete_all

test_insert_start = Time.now
10000.times do |i|
  Person.create!
end
test_insert_end = Time.now
puts "Test insert #{test_insert_end - test_insert_start}"

test_select_start = Time.now
Person.all
test_select_end = Time.now
puts "Test select #{test_select_end - test_select_start}"
