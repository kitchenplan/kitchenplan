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
require 'kitchenplan/resolver'

shared_examples "a Kitchenplan resolver" do
	let(:kr) { described_class.new(debug=true) }
	describe "#name" do
		it "returns a string" do
			expect(kr.name).to be_a(String)
		end
	end


end
