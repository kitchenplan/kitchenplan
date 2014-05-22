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
require 'kitchenplan/platform/linux'

describe Kitchenplan::Platform::Linux do
	it_behaves_like "a Kitchenplan platform"
	let(:kp) do
		kp = described_class.new(ohai=@fake_ohai)
		kp.stub(:sudo => true, :normaldo => true)
		kp
	end
	describe "#bundler_installed?" do
		it "should run 'gem spec bundler' on the host" do
			kp.stub(:'`' => "bundler")
			kp.should_receive(:'`').with(/gem spec bundler/)
			kp.bundler_installed?
		end
	end

	describe "#install_bundler" do
		context "if bundler is installed" do
			before do
				kp.stub(:bundler_installed? => true)
			end

			it "should return without calling sudo" do

				kp.should_not_receive(:sudo)
				kp.install_bundler()
			end
		end
		context "if bundler is not installed" do
			before do
				kp.stub(:bundler_installed? => false)
				enD
				it "should #sudo 'gem install bundler'" do
					kp.should_receive(:sudo).with(/gem install bundler/)
					kp.install_bundler()

				end
			end

		end
	end
	describe "#git_installed?" do
		it "should run 'git config' on the host" do
			kp.stub(:'`' => "git config")
			kp.should_receive(:'`').with(/git config/)
			kp.git_installed?
		end
	end
	describe "#user_is_admin?" do
		context "when the 'groups' command returns 'admin'" do
			before { kp.stub(:'`' => "admin wheel root") }
			it "returns true" do
				expect(kp.user_is_admin?).to eq true
			end
		end
		context "when the 'groups' command doesn not include 'admin'" do
			before { kp.stub(:'`' => "guest users apache") }
			it "returns false" do
				expect(kp.user_is_admin?).to eq false
			end
		end
	end
	describe "#prerequisites" do
		prereqs = %w{ running_as_normaluser? user_is_admin? version_supported? }
		before do
			Kitchenplan::Application.stub(:fatal!)
			prereqs.each { |f| kp.stub(f.to_sym => true ) }
		end

		prereqs.each do |func|
			context "when ##{func} is true" do
				before do
					kp.stub(func.to_sym => true)
				end
				it "logs no errors" do
					expect(Kitchenplan::Application).not_to receive(:fatal!)
					kp.prerequisites()
				end
			end
			context "when ##{func} is false" do
				before do
					kp.stub(func.to_sym => false)
					kp.stub(:install_bundler => true, :install_git => true, :kitchenplan_bundle_install => true)
				end
				it "logs a fatal error message" do
					expect(Kitchenplan::Application).to receive(:fatal!)
					kp.prerequisites()
				end
			end
		end
	end
end
