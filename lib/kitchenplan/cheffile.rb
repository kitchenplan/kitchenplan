module Kitchenplan

  class Cheffile

    attr_accessor :site, :cookbooks

    def initialize(cheffile)

      @cookbooks = []
      @site      = nil

      instance_eval File.read(cheffile)

    end

    def result
      result = { :site => @site, :cookbooks => @cookbooks }
      result
    end

    private

        def site(val)
          @site = val
        end

        def cookbook(name, options)
            cookbook = { :name => name, :options => options }
            @cookbooks.push(cookbook)
        end

  end

end