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

shared_examples "a Kitchenplan platform" do 
	let(:faux) { Fauxhai.mock(platform:'freebsd', version:'9.1') }
	let(:kp) { described_class.new(ohai=faux.data) }
	describe "#version_supported?" do
		context "when the lowest supported version is very low" do
			lvs = "0.1"
			it "returns true" do
				kp.instance_variable_set(:@lowest_version_supported, lvs)
				expect(kp.version_supported?).to be true
			end
		end
		context "when the lowest supported version is very high" do
			lvs = "999999"
			it "returns false" do
				kp.instance_variable_set(:@lowest_version_supported, lvs)
				expect(kp.version_supported?).to be false
			end
		end
	end
	describe "#run_privileged" do
		it "returns a string that's ready to be executed" do
			expect(kp.run_privileged("some-command")).to include("some-command")
		end
		#it "prepends sudo by default" do
		#	expect(kp.run_privileged("some-command","with-args")).to include("/usr/bin/sudo")
		#end
	end
	describe "#running_as_normaluser?" do
		context "Process UID is zero (superuser)" do
			it "returns false" do
				Process.stub(:uid) { 0 }
				expect(kp.running_as_normaluser?).to be false
			end
		end
		context "process UID is not zero (regular user)" do
			it "returns true" do
				Process.stub(:uid) { 501 }
				expect(kp.running_as_normaluser?).to be true
			end
		end

	end
	describe "#run_chef" do
		before do
			kp.stub(:sudo) { true }
		end
		it "runs chef-solo by default" do
			expect(kp.run_chef()).to include("bin/chef-solo")
		end
		context "param use_solo is true" do
			solo = true
			it "runs chef_solo" do
				expect(kp.run_chef(use_solo=solo)).to include("bin/chef-solo")
			end
		end
		context "param use_solo is false" do
			solo = false
			it "runs chef_solo" do
				expect(kp.run_chef(use_solo=solo)).to include("bin/chef-client -z")
			end
		end
	end
	describe "#sudo" do

		before do
			kp.stub(:system) { true }
			Kitchenplan::Log.stub(:info) { true }
			Kitchenplan::Log.stub(:debug) { true }
			kp.stub(:run_privileged) { "/usr/bin/sudo nonsense" }
		end
		it "logs the command via Logger object" do
			expect(Kitchenplan::Log).to receive :info
			kp.sudo "nonsense command"
		end
		it "calls run_privileged" do
			expect(kp).to receive :run_privileged
			kp.sudo "nonsense command"
		end
		it "passes the command arguments to Kernel#system" do
			expect(kp).to receive :system
			kp.sudo "nonsense command"
		end
	end
	describe "#normaldo" do
		before do
			kp.stub(:system) { true }
			Kitchenplan::Log.stub(:info) { true }
		end
		context "with an arbitrary command" do
			@cmd = "hello world"
			it "logs the command at info level" do
				expect(Kitchenplan::Log).to receive(:info).with(@cmd)
				kp.normaldo(@cmd)
			end
			it "passes the command to Kernel#system() unmodified" do
				expect(kp).to receive(:system).with(@cmd)
				kp.normaldo(@cmd)
			end
		end
	end
end
