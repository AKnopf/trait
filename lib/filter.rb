module Traits
  # An ExceptFilter causes all methods that are specified in ExceptFilter.[] to be skipped for the next Class or
  # Module in the ancestors. It can be used to define behavior where only a part of a module is included.
  # @example
  #   Module M1
  #     def a_method
  #       "a_method in M1"
  #     end
  #     def another_method
  #       "another_method in M1"
  #     end
  #   end
  #   Module M2
  #     def a_method
  #       "a_method in M2"
  #     end
  #     def another_method
  #       "another_method in M2"
  #     end
  #   end
  #   class C1
  #     include M2
  #     include M1
  #     include ExceptFilter[C1,M1,:a_method]
  #   end
  #   c = C1.new
  #   c.a_method #=> "a_method in M2"
  #   c.another_method #=> "another_method in M1"
  class ExceptFilter
    def self.[](base, _module, *methods)
      filter = Module.new do
        methods.each do |method|
          define_method method do |*args, &block|
            filter_index = base.ancestors.index(filter)
            super_super_type = base.ancestors[filter_index + 2]
            next_method = super_super_type.instance_method(method)
            next_method.bind(self).call(*args, &block)
          end
        end
      end
    end
  end


  # An OnlyFilter causes all methods that are _not_ specified in ExceptFilter.[] to be skipped for the next Class or
  # Module in the ancestors. It can be used to define behavior where only a part of a module is included.
  # @example
  #   Module M1
  #     def a_method
  #       "a_method in M1"
  #     end
  #     def another_method
  #       "another_method in M1"
  #     end
  #   end
  #   Module M2
  #     def a_method
  #       "a_method in M2"
  #     end
  #     def another_method
  #       "another_method in M2"
  #     end
  #   end
  #   class C1
  #     include M2
  #     include M1
  #     include OnlyFilter[C1,M1,:a_method]
  #   end
  #   c = C1.new
  #   c.a_method #=> "a_method in M1"
  #   c.another_method #=> "another_method in M2"
  class OnlyFilter
    def self.[](base,_module, *methods)
      all_methods = _module.instance_methods(false)
      except_methods = all_methods - methods
      ExceptFilter[base,_module, *except_methods]
    end
  end
end
