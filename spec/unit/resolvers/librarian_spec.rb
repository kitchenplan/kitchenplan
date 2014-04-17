require 'spec_helper'
require 'kitchenplan'
require 'kitchenplan/resolver/librarian'

describe Kitchenplan::Resolver::Librarian do
	#it_behaves_like "a Kitchenplan platform"
	let(:krl) { Kitchenplan::Resolver::Librarian.new() }
	describe "#name" do
		it "returns the name 'librarian-chef'" do
			expect(krl.name).to eq "librarian-chef"
		end
	end
	describe "#debug=" do
		context "when input is true" do
			it "sets @debug to true" do
				krl.debug=true
				expect(krl.instance_variable_get(:@debug)).to eq true
			end
		end
		context "when input is false" do
			it "sets @debug to false" do
				krl.debug=false
				expect(krl.instance_variable_get(:@debug)).to eq false
			end
		end
	end

	context "when @debug is true" do
		dbg = true
		before do
			krl.instance_variable_set(:@debug, dbg)
		end
		describe "#debug?" do
			it "returns true" do
				expect(krl.debug?).to eq true
			end
		end
		describe "#fetch_dependencies" do
			it "returns a command line with --verbose" do
				expect(krl.fetch_dependencies()).to include("--verbose")
			end
		end
		describe "#update_dependencies" do
			it "returns a command line with --verbose" do
				expect(krl.update_dependencies()).to include("--verbose")
			end
		end
	end
	context "when @debug is false" do
		dbg = false
		before do
			krl.instance_variable_set(:@debug, dbg)
		end
		describe "#debug?" do
			dbg = false
			it "returns false" do
				expect(krl.debug?).to eq false
			end
		end
		describe "#fetch_dependencies" do
			it "returns a command line with --quiet" do
				expect(krl.fetch_dependencies()).to include("--quiet")
			end
		end
		describe "#update_dependencies" do
			it "returns a command line with --verbose" do
				expect(krl.update_dependencies()).to include("--quiet")
			end
		end

	end
end
