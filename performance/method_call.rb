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

require 'benchmark'


module Traits
  module Hittable
    def update
      "update in hittable"
    end
  end

  class MonsterWithTraits
    include Traitable

    def update
      "update in monster"
    end

    incorporate.traits(:hittable)
    .resolve(:update)
      .with_lambda { update_in_monster_with_traits + update_in_hittable }
  end

  class MonsterWithMixins
    include Hittable
    def update
      "update in monster" + super
    end
  end
end


n = (1e7).to_i
Benchmark.bm(32) do |b|
  b.report('Call method within class with mixin: ') do
    monster = Traits::MonsterWithMixins.new
    n.times do
      monster.update
    end
  end
  b.report('Call method within class with trait: ') do
    monster = Traits::MonsterWithTraits.new
    n.times do
      monster.update
    end
  end
end

