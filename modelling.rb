require 'ostruct'

module Modelling

  class << self

    def append_features(receiver)
      initialize_members_classvar(receiver)
      bind_attributes_meta_method(receiver)
      bind_maps_meta_method(receiver)
      bind_collection_meta_method(receiver)
      build_structs_meta_method(receiver)
      bind_default_constructor(receiver)
    end

    def generate_accessors(receiver, names, initializer)
      receiver.instance_eval do
        names.each do |name|
          attr_accessor name
          @@members[self][name] = initializer
        end
      end
    end

    def generate_adhoc_accessors(receiver, names_to_class_or_proc)
      receiver.instance_eval do
        names_to_class_or_proc.each do |name, class_or_proc|
          attr_accessor name
          if class_or_proc.is_a?(Proc)
            @@members[self][name] = class_or_proc
          else
            @@members[self][name] = Proc.new { class_or_proc.new }
          end

        end
      end
    end

  private

    def initialize_members_classvar(receiver)
      receiver.instance_eval do
        @@members ||= {}; @@members[self] ||= {}
      end
    end

    def bind_meta_method(receiver, name, initializer)
      receiver.instance_eval { class << self; self; end }.instance_eval do
        define_method name do |*args|
          if args.last.is_a?(Hash)
            Modelling.generate_adhoc_accessors(self, args.pop)
          end
          Modelling.generate_accessors(self, args, initializer)
        end
      end
    end

    def bind_attributes_meta_method(receiver)
      bind_meta_method(receiver, :attributes, Proc.new { nil })
    end

    def bind_collection_meta_method(receiver)
      bind_meta_method(receiver, :collections, Proc.new { Array.new })
    end

    def bind_maps_meta_method(receiver)
      bind_meta_method(receiver, :maps, Proc.new { Hash.new })
    end

    def build_structs_meta_method(receiver)
      bind_meta_method(receiver, :structs, Proc.new { OpenStruct.new })
    end

    def bind_default_constructor(receiver)
      receiver.class_eval do
        def initialize(args = {})
          @@members[self.class].each do |accessor, initializer|
            send "#{accessor}=", initializer.call(self)
          end
          args.each { |name, value| send "#{name}=", value }
        end
      end
    end

  end

end
