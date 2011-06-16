module HasNormalizedSti
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_normalized_sti(options = {})
      extend  HasNormalizedSti::SingletonMethods
      include HasNormalizedSti::InstanceMethods

      class_eval <<-EVAL
        belongs_to :normal_type, :class_name => normal_type_class_name, :foreign_key => :type_id
        validates_associated :normal_type
        validates_presence_of :normal_type
      EVAL
    end
  end

  module SingletonMethods
    def normal_type_class_name
      "#{table_name.classify}Type"
    end

    def instantiate(record)
      associated_record = normal_type_class_name.constantize.find_by_id(record['type_id'])
      type_name = associated_record.try(:type_name)
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
      self.normal_type = self.class.normal_type_class_name.constantize.find_or_initialize_by_type_name(type_name)
    end
  end
end

ActiveRecord::Base.send :include, HasNormalizedSti
