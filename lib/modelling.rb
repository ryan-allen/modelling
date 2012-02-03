require 'modelling/version'
require 'ostruct'

module Modelling

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
    # A descendent gets a copy of the super classes
    # attributes when inheritence is used
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

end