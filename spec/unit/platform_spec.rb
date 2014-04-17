require 'spec_helper'
require 'kitchenplan'

describe Kitchenplan::Platform do
	it_behaves_like "a Kitchenplan platform"
	let(:faux) { Fauxhai.mock(platform:'freebsd', version:'9.1') }
	before do
		Kitchenplan::Log.stub(:warn)
	end
	describe "#initialize" do
		it "warns that the generic platform isn't implemented." do
			expect(Kitchenplan::Log).to receive :warn
			plat = described_class.new(ohai=faux.data)
		end
	end
	describe "#prerequisites" do
		it "warns that no prerequisites are defined" do
			expect(Kitchenplan::Log).to receive :warn
			plat = described_class.new(ohai=faux.data)
			plat.prerequisites()
		end
	end
end
