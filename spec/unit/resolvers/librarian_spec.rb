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
require 'kitchenplan/resolver/librarian'

describe Kitchenplan::Resolver::Librarian do
	it_behaves_like "a Kitchenplan resolver"
	let(:kr) { described_class.new(debug=true) }
	describe "#name" do
		it "returns the name 'librarian-chef'" do
			expect(kr.name).to eq "librarian-chef"
		end
	end

	context "when @debug is true" do
		dbg = true
		before do
			kr.instance_variable_set(:@debug, dbg)
		end
		describe "#fetch_dependencies" do
			it "returns a command line with --verbose" do
				expect(kr.fetch_dependencies()).to include("--verbose")
			end
		end
		describe "#update_dependencies" do
			it "returns a command line with --verbose" do
				expect(kr.update_dependencies()).to include("--verbose")
			end
		end
	end
	context "when @debug is false" do
		dbg = false
		before do
			kr.instance_variable_set(:@debug, dbg)
		end
		describe "#fetch_dependencies" do
			it "returns a command line with --quiet" do
				expect(kr.fetch_dependencies()).to include("--quiet")
			end
		end
		describe "#update_dependencies" do
			it "returns a command line with --verbose" do
				expect(kr.update_dependencies()).to include("--quiet")
			end
		end

	end


end
