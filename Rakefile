begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'has_normalized_sti'
    gem.summary     = 'allows rails STI to work when the type is normalized out'
    gem.description = <<-DESC
      has_normalzied_sti is a rails extension to allow Single Table Inheritance
      to work with a database normalized type column.
      The extension expects the STI model to have a type_id column instead of
      a type column. type_id should reference a Types table containg all the possible types.
      The types table will be auto populated with new types as new
      subclasses are saved.
    DESC
    gem.email       = 'kevin@glowacz.info'
    gem.author      = 'Kevin Glowacz'
    gem.files.exclude '.rvmrc'
  end
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
