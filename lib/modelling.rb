require 'modelling/version'
require 'ostruct'
require 'time'

module Modelling

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    def inherited(descendant)
      descendant.instance_variable_set(:@members, members.dup)
      super
    end

    def attributes(*args)
      generate_accessors_from_args(args, Proc.new { nil })
    end

    def collections(*args)
      generate_accessors_from_args(args, Proc.new { Array.new })
    end

    def maps(*args)
      generate_accessors_from_args(args, Proc.new { Hash.new })
    end

    def structs(*args)
      generate_accessors_from_args(args, Proc.new { OpenStruct.new })
    end

    def members
      @members ||= {}
    end
    
    def accessors
      @accessors ||= []
    end

    private

    def generate_accessors_from_args(args, default_initializer)
      names_to_initializer = args.last.is_a?(Hash) ? args.pop : {}
      args.each do |name|
        names_to_initializer[name] = default_initializer
      end
      generate_accessors(names_to_initializer)
    end

    def generate_accessors(names_to_initializer)
      names_to_initializer.each do |name, initializer|
        create_accessor(name)
        if initializer.is_a?(Proc)
          members[name] = initializer
        else
          members[name] = Proc.new { initializer.new }
        end
      end
    end

    def create_accessor(name)
      accessors << name
      instance_eval { attr_accessor name }
    end

  end

  def members
    self.class.members
  end

  def initialize(args = {})
    members.each do |accessor, initializer|
      if initializer.arity > 0
        send "#{accessor}=", initializer.call(self)
      else
        send "#{accessor}=", initializer.call
      end
    end
    args.each { |name, value| send "#{name}=", value }
  end
  
  def attributes
    hash = {}
    self.class.accessors.each do |method_name|
      hash[method_name] = send(method_name)
    end
    hash
  end
  
  def inspect
    attributes_as_nice_string = attributes.collect { |name, value|
      "#{name}: #{attribute_for_inspect(value)}"
    }.compact.join(", ")
    "#<#{self.class} #{attributes_as_nice_string}>"
  end
  
  def attribute_for_inspect(value)
    if value.is_a?(String) && value.length > 50
      "#{value[0..50]}...".inspect
    elsif value.is_a?(Date) || value.is_a?(Time)
      %("#{value.to_s(:db)}")
    elsif value.class.included_modules.include?(Modelling)
      "#<#{value.class.to_s}>"
    else
      value.inspect
    end
  end
  
end