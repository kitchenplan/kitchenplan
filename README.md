# Kitchenplan

Kitchenplan is a small tool to fully automate the installation and configuration of an OSX workstation (or server for
that matter) using Chef. But while doing so manually is not a trivial undertaking, Kitchenplan has abstracted away all
the hard parts.

## To Do

* debug options
* installing a manual list of recipes
* --no-chef
* only update cookbooks if we run with -c

## Using kitchenplan

### Installation

First of all, you need to install the kitchenplan gem. It only depends on [thor](http://whatisthor.com) so it won't
dirty up your brand new and clean install.

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

Do you have a config repository? [y,n]
```

If this is you first install using v2.1 of Kitchenplan, your aswer will be no. By doing so Kitchenplan will setup '/opt',
create the kitchenplan folder structure, setup a bare configuration and put it all in a local git repository. Put this
repository on Github (or any git server) and get to working on the configuration files.

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

Now, if you have a config repository, you don't want to start with a bare config but use your version. Answer yes and
enter your git repo in the next prompt. It will then fetch your configs.

```
Do you have a config repository? [y,n] y
Please enter the clone URL of your git config repository: https://github.com/roderik/kitchenplan-config.git
-> Making sure /opt exists and I can write to it
         run  sudo mkdir -p /opt from "."
         run  sudo chown -R roderik /opt from "."
-> Fetching https://github.com/roderik/kitchenplan-config.git to /opt/kitchenplan.
         run  git clone -q https://github.com/roderik/kitchenplan-config.git kitchenplan from "/opt"
```

### Editing the config files

### Running the install procedure

## Some blogposts about Kitchenplan

* [Setting up my perfect dev environment on OSX 10.9 using Chef / Kitchenplan](http://vanderveer.be/setting-up-my-perfect-dev-environment-on-osx-10-9-using-chef-kitchenplan/)
* [Presenting Kitchenplan @ vanderveer.be](http://vanderveer.be/blog/2013/04/14/presenting-kitchenplan/)

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

This project is inspired and built by using components and idea's from: Boxen, pivotal_workstation, Opscode cookbooks,
and more. Please take any imitation as a the highest form of flattery. If you feel the source or acknowledgements are
not sufficient, please let me know how you want it to be resolved.
