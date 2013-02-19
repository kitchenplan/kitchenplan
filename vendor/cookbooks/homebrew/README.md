Homebrew Cookbook [![Build Status](https://travis-ci.org/kitchenplan/chef-homebrew.png?branch=master)](https://travis-ci.org/kitchenplan/chef-homebrew)
=================

A cookbook, based on the Opscode Homebrew Cookbook but adjusted to work with soloist. Also moved and cleaned up some pivotal_workstation recipes.

Usage
-----

## package / homebrew\_package

This cookbook provides a package provider called `homebrew_package`
which will install/remove packages using Homebrew. This becomes the
default provider for `package` if your platform is Mac OS X.

As this extends the built-in package resource/provider in Chef, it has
all the resource attributes and actions available to the package
resource. However, a couple notes:

* Homebrew itself doesn't have a notion of "upgrade" per se. The
  "upgrade" action will simply perform an install, and if the Homebrew
  Formula for the package is newer, it will upgrade.
* Likewise, Homebrew doesn't have a purge, but the "purge" action will
  act like "remove".

### Examples

    package "mysql" do
      action :install
    end

    homebrew_package "mysql"

    package "mysql" do
      provider Chef::Provider::Package::Homebrew
    end

## homebrew\_tap

LWRP for `brew tap`, a Homebrew command used to add additional formula
repositories. From the `brew` man page:

    tap [tap]
           Tap a new formula repository from GitHub, or list existing taps.

           tap is of the form user/repo, e.g. brew tap homebrew/dupes.

Default action is `:tap` which enables the repository. Use `:untap` to
disable a tapped repository.

### Examples

    homebrew_tap "homebrew/dupes"

    homebrew_tap "homebrew/dupes" do
      action :untap
    end

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
5. Run the tests, ensuring they all pass (on Travis)
6. Submit a Pull Request using Github
