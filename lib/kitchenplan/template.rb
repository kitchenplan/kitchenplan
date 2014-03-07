require 'erb'
require 'ostruct'

module Kitchenplan

  # http://stackoverflow.com/questions/8954706/render-an-erb-template-with-values-from-a-hash

  class Template < OpenStruct

    def self.render_from_hash(template, hash)
      Template.new(hash).render(template)
    end

    def render(template)
      ERB.new(template, 0, '-').result(binding)
    end

  end

end

