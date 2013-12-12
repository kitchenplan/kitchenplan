# Kitchenplan

## Why Kitchenplan?

Read about this project and it's values and goals in this blog post: [http://vanderveer.be/blog/2013/04/14/presenting-kitchenplan/](http://vanderveer.be/blog/2013/04/14/presenting-kitchenplan/)

## Using Kitchenplan

I myself will use this version, so you can learn from my config files. But you best start of by forking this repo. You will need it to store your configuration files. See the Custom Repository section for more info.

On OSX 10.8 Mountain Lion you should install XCode and the Command Line Tools from within XCode before you start. For 10.9 Mavericks the script will prompt you to install the Command Line Tools automatically.

Now, to get Kitchenplan on your computer, run the following commands:

```bash
ruby -e "$(curl -fsSL https://raw.github.com/kitchenplan/kitchenplan/master/go)"
```

### Custom Repository

If the repo for your organisation is private, continue with setting up your SSH keys. Open up a Terminal window and run ```ssh-keygen```. After this command finishes, run ```cat ~/.ssh/id_rsa.pub``` and copy the output. Put this in your Github account or where you need your private key in your repo hosting of your choice.

The `KITCHENPLAN_REPO` environment variable can be set before installation to customize what git repository is used for kitchen plan.

```bash
$ export KITCHENPLAN_REPO=https://github.com/mycompany/kitchenplan.git
$ ruby -e "$(curl -fsSL https://raw.github.com/kitchenplan/kitchenplan/master/go)"
```

### Custom Recipes

Before you run the commadn above, or manually run the```./kitchenplan``` command, you should first create a custom config file. The config system will always start off with ```default.yml```. This will contain the recipes for every person in your organisation. Next it it will look at the file ```yourusername.yml``` (with the username logged in on the computer as yourusername) for your custom settings. Ofcourse there will be a lot of shared config when your organisation has departments of different types of personel. So you can define group config files and assign one or more groups to a user. The ```roderik.yml``` ([found here](https://github.com/kitchenplan/kitchenplan/blob/master/config/people/roderik.yml)) is my personal config file and it will fall back to this config if you don't have a personal file.

When you are done with that, run the go script or run ```kitchenplan``` manually and wait for a while. After the command finishes, reboot your computer and you are good to go.

### Command line tools

There are some useful command line options, run ```kitchenplan -d``` or look here:

```
Usage: kitchenplan [options]
    -d, --debug                      Show debug information
    -c, --update-cookbooks           Update the Chef cookbooks
        --[no-]chef                  Run chef (defaults to yes)

Common options:
    -h, --help                       Show this message
        --version                    Show version
```

### Caveat

We are running this project in production for both OSX and Ubuntu development machines. So I'm pretty sure it all works just fine. But, in the gap between two new installs, all the applications we install, and all community cookbooks are in constant development and can potentially break the install. I always suggest to our people that they run it first in a virtual machine (You can easily install OSX in a VMware Fusion trial, or use Vagrant for Linux testing).

### Want to contribute?

Fork and send pull requests or just idea's and issues via the issue tracker. If you need a new recipe, fork the chef-* repo's and change the url in the Cheffile to make it fetch your version. Add it and send a pull request. For now we support OSX and the debian family (only tested on Ubuntu). Other operating systems are welcome!

More questions, ping me at [Twitter @r0derik](http://twitter.com/r0derik) or visit our [HipChat channel](https://www.hipchat.com/gTkMJo2Ag).

### Acknowledgements

This project is inspired and built by using components and idea's from: Boxen, pivotal_workstation, Opscode cookbooks, and more. Please take any imitation as a the highest form of flattery. If you feel the source or acknowledgements are not sufficient, please let me know how you want it to be resolved.
