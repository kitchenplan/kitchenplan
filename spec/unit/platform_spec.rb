# Copyright 2014 Disney Enterprises, Inc. All rights reserved
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are
#  met:
#
#   * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
#
#   * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in
#   the documentation and/or other materials provided with the
#   distribution.

require 'spec_helper'
require 'kitchenplan'

describe Kitchenplan::Platform do
	it_behaves_like "a Kitchenplan platform"
	let(:plat) { described_class.new(ohai=@fake_ohai) }
	before do
		Kitchenplan::Log.stub(:warn)
	end
	describe "#initialize" do
		it "warns that the generic platform isn't implemented." do
			expect(Kitchenplan::Log).to receive :warn
			plat = described_class.new(ohai=@fake_ohai)
		end
	end
	describe "#prerequisites" do
		it "warns that no prerequisites are defined" do
			expect(Kitchenplan::Log).to receive :warn
			plat.prerequisites()
		end
	end
	describe "#run_privileged" do
		context "when /usr/bin/sudo is the first parameter" do
			args = ["/usr/bin/sudo","do things","and do them now"]
			it "doesn't duplicate /usr/bin/sudo on the returned command line" do
				expect(plat.run_privileged("/usr/bin/sudo","do things","and do them now").select { |a| a == "/usr/bin/sudo" }.length).to eq 1
			end
		end
	end
end
