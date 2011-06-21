module HasNormalizedSti
  def self.included(base)
    base.extend(ClassMethods)
  end

  # This extension will allow Rails STI to work a normalized type column.

  # For example

  #   create_table :people, :force => true do |t|
  #     t.string  :full_name
  #     t.integer :type_id
  #   end

  #   create_table :person_types, :force => true do |t|
  #     t.string :type_name
  #   end

  #   class Person < ActiveRecord::Base
  #     has_normalized_sti
  #   end

  #   class PersonType < ActiveRecord::Base
  #   end

  #   after calling has_normalized_sti:
  #   * <tt>type</tt> - returns the name of the class of the type just as regular STI
  #   * <tt>type=</tt> - set the type to something specific like regular STI
  #   * <tt>normal_type</tt> - the Type object through the relation
  module ClassMethods
    # Configuration options are:
    #
    #   * type_class_name - belong_to this model for the type storage
    #     (default: #{class_name}Type)
    #   * foreign_key - specifies the column for id of the type (default: type_id)
    #   * type_column - specifies the column name for the type string on the types table
    #     (default: type_name)
    def has_normalized_sti(options = {})
      extend  HasNormalizedSti::SingletonMethods
      include HasNormalizedSti::InstanceMethods

      class_inheritable_accessor :sti_config
      self.sti_config = {
        :type_class_name => "#{table_name.classify}Type",
        :foreign_key => 'type_id',
        :type_column => 'type_name'
      }
      sti_config.update(options)
      sti_config[:type_class_name] = sti_config[:type_class_name].to_s.classify

      begin
        sti_config[:type_class_name].constantize
      rescue NameError
        txt = "has_normalized_sti could not load #{sti_config[:type_class_name]}\n"
        txt << "please make sure #{sti_config[:type_class_name]} is loaded before #{self.to_s}\n"
        txt << "you might need to add require_dependency '#{sti_config[:type_class_name].underscore}'\n"
        txt << "to #{self.to_s.underscore}.rb"
        raise LoadError, txt
      end

      belongs_to :normal_type, :class_name => sti_config[:type_class_name], :foreign_key => sti_config[:foreign_key]
      default_scope joins(:normal_type).select("#{table_name}.*, #{sti_config[:type_class_name].constantize.table_name}.#{sti_config[:type_column]}")
      validates_associated :normal_type
      validates_presence_of :normal_type
    end
  end

  module SingletonMethods
    def instantiate(record)
      if record.has_key?(sti_config[:type_column])
        type_name = record[sti_config[:type_column]]
      else
        associated_record = sti_config[:type_class_name].constantize.find_by_id(record[sti_config[:foreign_key].to_s])
        type_name = associated_record.try(sti_config[:type_column])
      end
      model = find_sti_class(type_name).allocate
      model.init_with('attributes' => record)
      model
    end

    def find_sti_class(type_name)
      if type_name.blank?
        self
      else
        begin
          if store_full_sti_class
            ActiveSupport::Dependencies.constantize(type_name)
          else
            compute_type(type_name)
          end
        rescue NameError
          raise SubclassNotFound,
            "The single-table inheritance mechanism failed to locate the subclass: '#{type_name}'. " +
            "This error is raised because the column '#{inheritance_column}' is reserved for storing the class in case of inheritance. " +
            "Please rename this column if you didn't intend it to be used for storing the inheritance class " +
            "or overwrite #{name}.inheritance_column to use another column for that information."
        end
      end
    end

    def descends_from_active_record?
      if superclass.abstract_class?
        superclass.descends_from_active_record?
      else
        superclass == ActiveRecord::Base
      end
    end

    def type_condition
      sti_column = sti_config[:type_class_name].constantize.arel_table[sti_config[:type_column]]
      condition = sti_column.eq(sti_name)
      descendants.each { |subclass| condition = condition.or(sti_column.eq(subclass.sti_name)) }

      condition
    end
  end

  module InstanceMethods
    def initialize(attributes = {})
      super
      self.type = self.class.to_s
    end

    def type
      self.normal_type.try(sti_config[:type_column]) || self.class.to_s
    end

    def type=(type_name)
      type_class = self.class.sti_config[:type_class_name].constantize
      self.normal_type = type_class.send("find_or_initialize_by_#{sti_config[:type_column]}", type_name)
    end
  end
end

ActiveRecord::Base.send :include, HasNormalizedSti
