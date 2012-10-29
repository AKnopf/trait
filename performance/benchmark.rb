require 'benchmark'


require_relative '../lib/core_extensions/array'
require_relative '../lib/core_extensions/hash'
require_relative '../lib/core_extensions/module'
require_relative '../lib/core_extensions/string_and_symbol'
require_relative '../lib/builder'
require_relative '../lib/filter'
require_relative '../lib/incorporation'
require_relative '../lib/trait'
require_relative '../lib/traitable'
require_relative '../lib/traits_home'



module Traits
  module Hittable
    def update
      "update in hittable"
    end
  end

  module Position
    def update
      "update in position"
    end
  end
end


n = 50000

Benchmark.bm(20) do |b|
  b.report('Call method on mixed in class: ') do
    klass = Class.new do
      include Traits::Traitable
      incorporate.traits(:hittable, :position)
      .and
      .resolve(:update)
        .with_pattern
        .call_in_order
      .done
    end

    object = klass.new
    raise object.update_in_hittable.inspect
    n.times do
      object.update
    end
  end


  b.report('Define class with mixin: ') do
    n.times do
      Class.new do
        include Traits::Hittable
        include Traits::Position
      end
    end
  end

  b.report('Define class with trait: ') do
    n.times do
      Class.new do
        include Traits::Traitable
        incorporate.traits(:hittable, :position)
        .and
        .resolve(:update)
        .with_pattern
        .call_in_order
        .done
      end
    end
  end

  b.report('Call method on mixed in class: ') do
    klass = Class.new do
      include Traits::Hittable
      include Traits::Position
    end

    object = klass.new

    n.times do
      object.update
    end
  end

end

