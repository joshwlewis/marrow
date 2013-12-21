class Marrow
  VERSION = '0.0.1'
  class << self
    def new_class(*keys)
      Class.new(self) do |klass|
        self.table_keys = (keys + superclass.table_keys).uniq
      end
    end

    def new(*args)
      if self < Marrow
        super(*args)
      else
        new_class(*args)
      end
    end

    def table_keys
      @table_keys ||= []
    end
    protected :table_keys

    def table_keys=(keys)
      keys = keys.map(&:to_sym)
      keys.each do |key|
        define_method(key) do
          self[key]
        end
        define_method("#{key}=") do |value|
          self[key] = value
        end
      end
      @table_keys = keys
    end
    protected :table_keys=
  end
  attr_reader :table
  protected :table

  def initialize(hash=nil)
    @table = table_keys.inject({}){ |h,k| h[k]=nil;h }
    if hash
      hash.each do |k,v|
        self[k] = hash[k]
      end
    end
  end

  def table_keys
    self.class.send(:table_keys)
  end
  private :table_keys

  def [](key)
    @table[key.to_sym]
  end

  def []=(key,value)
    key = key.to_sym
    if table_keys.include?(key)
      @table[key] = value
    else
      raise ArgumentError, "Invalid marrow attribute: '#{key}'."
    end
  end

  def inspect
    attribute_string = @table.map{|k,v| "#{k}=#{v.inspect}"}.join(', ')
    "#<#{self.class} #{attribute_string}>"
  end
end
