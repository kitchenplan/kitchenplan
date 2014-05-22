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
require 'kitchenplan/platform/windows'

describe Kitchenplan::Platform::Windows do
	it_behaves_like "a Kitchenplan platform"
	let(:fake_ohai) do
		{
			"fqdn" => "hostname.example.org",
			"hostname" => "hostname",
			"machinename" => "machinename",
			"platform" => "windows-example",
			"platform_version" => "1.0",
			"platform_family" => "windows",
			"data" => {}
		}
	end
	let(:kp) do
		Kitchenplan::Application.stub(:fatal!)
		kp = Kitchenplan::Platform::Windows.new(ohai=fake_ohai)
		kp.stub(:sudo => "", :normaldo => "")
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
	describe "#prerequisites" do
		it "should call #install_bundler" do
			expect(kp).to receive :install_bundler
			kp.prerequisites()
		end
		it "should call #install_git" do
			expect(kp).to receive :install_git
			kp.prerequisites()
		end
		it "should call #kitchenplan_bundle_install" do
			expect(kp).to receive :kitchenplan_bundle_install
			kp.prerequisites()
		end
	end
	describe "#kitchenplan_bundle_install" do
		it "runs sudo with the 'bundle install' command" do
			expect(kp).to receive(:sudo).with(/bundle\.bat install/)
			kp.kitchenplan_bundle_install()
		end
	end
	describe "#run_privileged" do
		context "with multiple string parameters" do
			*args = ["many","things","--with","more-params.txt"]
			it "returns an execution string containing the parameters" do
			expect(kp.run_privileged(args)).to include("things")
			end
		end
		context "with a single parameter" do
			*args = ["oneparameter"]
			it "returns an execution string containing the single parameter" do
			expect(kp.run_privileged(args)).to include("oneparameter")
			end
		end
	end
end
