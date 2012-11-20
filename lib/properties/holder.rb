module Properties
  class PropertiesHolder
    def initialize
      @@properties ||= {}
    end

    def []=(key,value)
      @@properties[_to_sym(key)] = value
    end

    def [](key)
      @@properties[_to_sym(key)]
    end

    def has_key?(key)
      @@properties.has_key?(_to_sym(key))
    end

    def _to_sym(key)
      key = key.to_sym unless key.is_a?(Symbol)
      key
    end
  end
end