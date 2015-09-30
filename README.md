**[I've recently released a new, cleaner, faster solution based on Ansible. Please read about it in this blog post](http://vanderveer.be/2015/09/27/using-ansible-to-automate-osx-installs-via-superlumic.html)**

# Kitchenplan

Kitchenplan is a small tool to fully automate the installation and configuration of an OSX workstation (or server for that matter) using Chef. But while doing so manually is not a trivial undertaking, Kitchenplan has abstracted away all the hard parts.

## Using kitchenplan

### Installation

First of all, you need to install the kitchenplan gem. It only depends on [thor](http://whatisthor.com), [gabba](https://github.com/hybridgroup/gabba) and [deep_merge](https://github.com/danielsdeleo/deep_merge) so it won't dirty up your brand new and clean install.

```
gem install kitchenplan
```

### Setting up

Next up we can start the setup of Kitchenplan. Just run `kitchenplan setup` and you will see the following prompt

```
  _  ___ _       _                      _
 | |/ (_) |     | |                    | |
 | ' / _| |_ ___| |__   ___ _ __  _ __ | | __ _ _ __
 |  < | | __/ __| '_ \ / _ \ '_ \| '_ \| |/ _` | '_ \
 | . \| | || (__| | | |  __/ | | | |_) | | (_| | | | |
 |_|\_\_|\__\___|_| |_|\___|_| |_| .__/|_|\__,_|_| |_|
                                 | |
                                 |_|

-> Installing XCode CLT
         run  sw_vers -productVersion | awk -F "." '{print $2}' from "."
         run  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress from "."
         run  softwareupdate -l | grep -B 1 "Developer" | head -n 1 | awk -F"*" '{print $2}' from "."
         run  softwareupdate -i  -v from "."

Do you have a config repository? [y,n] n
```

If this is your first install using v2.1 of Kitchenplan, your aswer will be no. By doing so Kitchenplan will setup '/opt', create the kitchenplan folder structure, setup a bare configuration and put it all in a local git repository. Put this repository on Github (or any git server) and get to working on the configuration files.

```
-> Making sure /opt exists and I can write to it
         run  sudo mkdir -p /opt from "."
         run  sudo chown -R roderik /opt from "."
-> Creating the config folder structure
         run  mkdir -p kitchenplan from "/opt"
         run  mkdir -p config from "/opt/kitchenplan"
         run  mkdir -p groups from "/opt/kitchenplan/config"
         run  mkdir -p people from "/opt/kitchenplan/config"
-> Creating the template config files
      create  /opt/kitchenplan/README.md
      create  /opt/kitchenplan/config/default.yml
      create  /opt/kitchenplan/config/groups/groupa.yml
      create  /opt/kitchenplan/config/groups/groupb.yml
      create  /opt/kitchenplan/config/people/roderik.yml
-> Preparing the Cookbook configuration
      create  /opt/kitchenplan/Cheffile
-> Setting up the git repo
      create  /opt/kitchenplan/.gitignore
         run  git init -q from "/opt/kitchenplan"
         run  git add -A . from "/opt/kitchenplan"
         run  git commit -q -m 'Clean installation of the Kitchenplan configs for user roderik' from "/opt/kitchenplan"
=> Now start editing the config files in /opt/kitchenplan/config, push them to a git server and run 'kitchenplan provision'
```

Now, if you have a config repository, you don't want to start with a bare config but use your version. Answer yes and enter your git repo in the next prompt. It will then fetch your configs.

```
Do you have a config repository? [y,n] y
Please enter the clone URL of your git config repository: https://github.com/roderik/kitchenplan-config.git
-> Making sure /opt exists and I can write to it
         run  sudo mkdir -p /opt from "."
         run  sudo chown -R roderik /opt from "."
-> Fetching https://github.com/roderik/kitchenplan-config.git to /opt/kitchenplan.
         run  git clone -q https://github.com/roderik/kitchenplan-config.git kitchenplan from "/opt"
```

*WARNING: Chef v12 breaks everyhting related to the way users work in Kitchenplan. Please update your Gemfile to look like:*

```
source "https://rubygems.org"

gem "chef", "~> 11.0"
gem "librarian-chef", "~> 0.0.2"
```

### Editing the config files in /opt/kitchenplan/config

The most important file is named after your user in config/people/. In my case a roderik.yml file since my username on my Mac is roderik. When running `kitchenplan setup` will create a YAML file in this folder with your username. You can use your config repository for everyone in your organisation by adding a file per username in the people folder.

The final config that will be compiled, will be default.yml + username.yml + the group YAML files defined in username.yml + the group YAML files defined in those groups + the group YAML files defined in default.yml. Everything that is a "list" is appended to each other, single value's are overridden.

Now, how you organise your config files is entirely up to you, but this is how I do it. default.yml are the apps that everyone in my company needs. Then I have a group file per department in our company, and sometimes for a specific subset of people in that department.

If you want to see [a fully implemented example, please see my config repository](https://github.com/roderik/kitchenplan-config)

### Running the install procedure

Running Kitchenplan is as easy as running `kitchenplan provision`

```
  _  ___ _       _                      _
 | |/ (_) |     | |                    | |
 | ' / _| |_ ___| |__   ___ _ __  _ __ | | __ _ _ __
 |  < | | __/ __| '_ \ / _ \ '_ \| '_ \| |/ _` | '_ \
 | . \| | || (__| | | |  __/ | | | |_) | | (_| | | | |
 |_|\_\_|\__\___|_| |_|\___|_| |_| .__/|_|\__,_|_| |_|
                                 | |
                                 |_|

-> Setting up bundler
      create  /opt/kitchenplan/Gemfile
         run  mkdir -p vendor/cache from "/opt/kitchenplan"
         run  rm -rf vendor/bundle/config from "/opt/kitchenplan"
         run  bundle install --quiet --binstubs vendor/bin --path vendor/bundle from "/opt/kitchenplan"
-> Sending a ping to Google Analytics
-> Compiling configurations
         run  mkdir -p tmp from "/opt/kitchenplan"
-> Fetch the chef cookbooks
         run  vendor/bin/librarian-chef install --clean --quiet --path=vendor/cookbooks from "/opt/kitchenplan"
         run  sudo vendor/bin/chef-solo -c tmp/solo.rb -j tmp/kitchenplan-attributes.json -o applications::create_var_chef_cache,homebrewalt::default,nodejs::default,... from "/opt/kitchenplan"
```

At this point Chef will start installing everything you configured. Depending on your install list, this might take a while. It will hopefully go smooth and end with

```
-> Cleanup parsed configuration files
         run  rm -f kitchenplan-attributes.json from "/opt/kitchenplan"
         run  rm -f solo.rb from "/opt/kitchenplan"
=> Installation complete!
```

## Some blogposts about Kitchenplan

* [Setting up my perfect dev environment on OSX 10.9 using Chef / Kitchenplan](http://vanderveer.be/setting-up-my-perfect-dev-environment-on-osx-10-9-using-chef-kitchenplan/)
* [Presenting Kitchenplan @ vanderveer.be](http://vanderveer.be/blog/2013/04/14/presenting-kitchenplan/)

## History

This is a brand new implementation of Kitchenplan. If you have issues with this new versions, please use [version2](https://github.com/kitchenplan/kitchenplan/blob/version2/README.md) for now.

## Contributing to kitchenplan

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Roderik van der Veer. See LICENSE.txt for further details.

## Acknowledgements

This project is inspired and built by using components and idea's from: Boxen, pivotal_workstation, Opscode cookbooks, and more. Please take any imitation as a the highest form of flattery. If you feel the source or acknowledgements are not sufficient, please let me know how you want it to be resolved.
