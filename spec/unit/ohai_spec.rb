require 'spec_helper'
require 'ohai'
require 'kitchenplan'

describe Ohai::System do
	let(:ohai) { Ohai::System.new }

	%w{ os platform }.each do |n|
		it "should load the required #{n} ohai plugin" do
			expect(ohai.require_plugin(n)).to eq(true)
			expect(ohai.seen_plugins).to include(n => true)
			expect(ohai.data).to include(n)
		end
	end
end
