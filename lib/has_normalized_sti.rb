module HasNormalizedSti
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_normalized_sti(options = {})
    end
  end
end

ActiveRecord::Base.send :include, HasNormalizedSti
