module HasNormalizedSti
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
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

      belongs_to :normal_type, :class_name => sti_config[:type_class_name], :foreign_key => sti_config[:foreign_key]
      validates_associated :normal_type
      validates_presence_of :normal_type
    end
  end

  module SingletonMethods
    def instantiate(record)
      associated_record = sti_config[:type_class_name].constantize.find_by_id(record[sti_config[:foreign_key].to_s])
      type_name = associated_record.try(sti_config[:type_column])
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
  end

  module InstanceMethods
    def initialize(attributes = {})
      super
      self.type = self.class.to_s
    end

    def type
      self.class.to_s
    end

    def type=(type_name)
      type_class = self.class.sti_config[:type_class_name].constantize
      self.normal_type = type_class.send("find_or_initialize_by_#{sti_config[:type_column]}", type_name)
    end
  end
end

ActiveRecord::Base.send :include, HasNormalizedSti
