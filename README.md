# Kitchenplan

## Why Kitchenplan?

In the recent past, I've been bitten by the [Chef](http://www.opscode.com/chef/) virus and I've used it to install and configure my Mac. The parts of that setup are described in detail in this blogpost: [Automating the Setup of My Perfect Developer Environment on OSX 10.8 Mountain Lion](http://vanderveer.be/blog/2013/01/02/automating-the-setup-of-my-perfect-developer-environment-on-osx-10-dot-8-mountain-lion/). Central in this story was the [pivotal_workstation project](https://github.com/pivotal/pivotal_workstation), this project by [Pivotal Labs](http://pivotallabs.com/) is used to setup the workstations at Pivotal Las, and as such any and especially my involvement with the project was limited to writing new recipes within the structure and default behaviour that was predefined.

While learing more about Chef and Ruby in general, I learend that this default frame had some issues, or at least so it seems to me. It uses almost no third party community cookbooks and it is used as a working tool for a company and as a result of that possible changes are limited. For example Linux support, big changes that need integration in the Pivotal workfloware slow, etc. Understandable, but limiting what I wanted to do.

A while back GitHub released [Boxen](http://boxen.github.com/). Boxen has the same goals as pivotal_workstation, but uses Puppet. Where Boxen excells was in the delivery method (oneline installers, dependency management) and the cleanliness of the manifest files. But unfortunately, it also has some issues where I cannot look past. First off, I want to use tools like rbenv/rvm and Homebrew like they are meant to be used, and not some weird custom setup. It also uses Puppet, and this is no fault of GitHub, Puppet or Boxen, but I just cannot get Puppet to do what I want, my bad, but it's the truth.

So I started to write Kitchenplan, and by write I also mean lots of copy/paste from other projects. Kitchenplan is based around a few principles. I want it's installation to be as flawless, smooth and easy as Boxen. I want it to be based on Chef, librarian-chef and soloist. I want to use as much community work as possible and make very clean and easy to maintain recipes. These recipes will also be as "default" as possible (so no special Homebrew installs) it should be alble to support Linux and it shouldn't destroy your prompt and ruby setup if you sudo to another user.

It will inherit one flaw from both Boxen and Pivotal workstation, I will be using it to manage the workstations at [Kunstmaan](http://www.kunstmaan.be/) but I will try to keep everything as default as possible so it will port to another company easily. This is why I used a different org on Github to make it more generic.

## Using Kitchenplan

### As a Kitchenplan maintainer for your organisation or for personal use.

I myself will use this version, so you can learn from my config files. By you best start of by forking this repo. You will need it to store your configuration files. If you want to make it private, read up on how Boxen suggest you do this: https://github.com/boxen/our-boxen#bootstrapping

### Getting started as a user

To get started, open up the App Store application and install the latest XCode. After XCode is installed, go to the Preferences and install the Command Line Tools. At this point you have both a compiler and a GIT binary, so we can go to the next step.

![Installing Command Line Tools](http://vanderveer.be/images/2012-04-21/Xcode-Downloads.png)

If the repo for your organisation is private, continue with setting up your SSH keys. Open up a Terminal window and run ```ssh-keygen```. After this command finishes, run ```cat ~/.ssh/id_rsa.pub``` and copy the output. Put this in your Github account or where you need your private key in your repo hosting of your choice.

Now, to get Kitchenplan on your computer, run the following commands:

```bash
sudo mkdir -p /opt
sudo chown -R $USER /opt
cd /opt
git clone https://github.com/kitchenplan/kitchenplan.git kitchenplan # or your version
sudo ln -sf /opt/kitchenplan/kitchenplan /usr/bin/kitchenplan
```

Before you run the ```kitchenplan``` command, first create a custom config file. The config system will always start of with ```default.yml```. This will contain the recipes for every person in your organisation. Next it it will look at the file ```yourusername.yml``` (with the username logged in on the computer as yourusername) for your custom settings. Ofcourse there will be a lot of shared config when your organisation has departments of different types of personel. So you can define group config files and assign one or more groups to a user.

When you are done with that, run ```kitchenplan``` and wait for a while. After the command finishes, reboot your computer and you are good to go.

### Want to contribute?

Fork and send pull requests or just idea's and issues via the issue tracker. If you need a new recipe, fork the chef-* repo's and change the url in the Cheffile to make it fetch your version. Add it and send a pull request. More questions, ping me at [Twitter @r0derik](http://twitter.com/r0derik).
