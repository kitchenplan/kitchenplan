# Our Kitchenplan

I believe everyone has heard of the Boxen project by GitHub? Well, since I'm unable to bend Puppet to do my bidding, and I've invested a whole lot of time in a Chef setup to setup our office computers, I decided to take the parts I like from Boxen, and combine them with everything I contributed in pivotal_workstation (and some parts I didn't), and create Kitchenplan.

Kitchenplan is based around a few principles. I want it's installation to be as flawless, smooth and easy as Boxen. I want it to be based on Chef, librarian-chef and soloist. I want to use as much community work as possible and make very clean and easy to maintain recipes. These recipes will also be as "default" as possible (so no special Homebrew installs) and it shouldn't destroy your prompt and ruby setup if you sudo to another user.

This is a template Kitchenplan project designed for your organization to duplicate and modify appropriately.

## Getting started for development

1. Install Xcode Command Line Tools and/or full Xcode.
  * If using full Xcode, you'll need to install the developer tools from the preferences in Xcode
1. Create a new repository on GitHub as your user for your Kitchenplan. (eg. `my-org/kitchenplan`). **Make sure it is a private repository!**
1. Get running manually like so:

```bash
  mkdir -p ~/src/kitchenplan
  cd ~/src/kitchenplan
  git init
  git remote add upstream https://github.com/kitchenplan/our-kitchenplan
  git fetch upstream
  git checkout -b master upstream/master
  git remote add origin https://github.com/my-org/kitchenplan # Change this to your own repository from step 2
  git push origin master
  sudo mkdir -p /opt/kitchenplan
  sudo chown $USER:admin /opt/kitchenplan
  ln -sf ~/src/kitchenplan /opt/kitchenplan/repo
  ln -sf /opt/kitchenplan/repo/kitchenplan /usr/bin/kitchenplan
  kitchenplan
```

Now you have your own kichenplan repo that you can hack on.

## Getting your users started _after_ your "fork" exists

1. Install the Xcode Command Line Tools (full Xcode install optional).
1. Point them at your private install of [kitchenplan-web](https://github.com/kitchenplan/kitchenplan-web) and run the command
1. Wait...
1. Done

If you did this user version of the install, the /opt/kitchenplan/repo will not be a git repository. If you want to work on your own user.ym file, just clone your private repo somewhere and add/edit it. After committing and pushing (your maintainer might require a pull request), execute the following and then rerun the installation command.

```bash
rm /opt/kitchenplan/repo/.snapshot
```
