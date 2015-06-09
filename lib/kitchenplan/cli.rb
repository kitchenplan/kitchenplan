require 'thor'

module Kitchenplan
  class Cli < Thor
    include Thor::Actions

    option :gitrepo, :type => :string, :desc => 'Repo with kitchenplan configs', :default => nil
    option :config, :type => :boolean, :desc => 'Create <username>.yml'
    desc 'setup [<target directory>] [--config] [--gitrepo=http://...]', 'Setup your workstation to run Kitchenplan and create an example configuration'
    long_desc <<-LONGDESC
    `kitchenplan setup` will install the dependencies of Kitchenplan and create a configuration in /opt/kitchenplan (or <target directory>
    if you pass it along) to use with the `kitchenplan provision` command.

    If you already have a configuration stored in git somewhere, it will ask you to pass the git repo url. If you want to bypass the
    prompt, pass it along on the commandline. (see .travis.yml for an example)
    LONGDESC
    def setup(targetdir='/opt')
      gitrepo = options[:gitrepo]
      logo
      install_clt unless File.exist? "/Library/Developer/CommandLineTools/usr/bin/clang"
      if gitrepo || File.exists?("#{targetdir}/kitchenplan")
        fetch(gitrepo, targetdir)
      else
        has_config = yes?('Do you have a config repository? [y,n]', :green)
        if has_config
          gitrepo = ask('Please enter the clone URL of your git config repository:', :green)
          fetch(gitrepo, targetdir)
        else
          create(targetdir)
        end
      end
      unless File.exists?("#{targetdir}/kitchenplan/config/people/#{ENV['USER']}.yml")
        user_create = options[:config]
        user_create = yes?("config/people/#{ENV['USER']}.yml does not exist. Do you wish to create it? [y,n]", :green) if user_create.nil?
        if user_create
          create_user(targetdir)
        end
      end
    end

    option :debug, :type => :boolean
    option 'no-fetch', :type => :boolean
    option :recipes, :type => :array
    option :solorb, :type => :string, :default => 'tmp/solo.rb'
    desc 'provision [<target directory>] [--debug] [--recipes=x y z] [--solorb=path] [--no-fetch]', 'Provision your workstation with Kitchenplan'
    long_desc <<-LONGDESC
    `kitchenplan provision` will use the configuration in /opt/kitchenplan (or <target directory>
    if you pass it along) to provision your workstation using Chef.

    You can optionally pass --debug to see more detail of what's happening.

    Passing --no-fetch will skip updating the librarian sources from remote sources.

    If you just want to install a few recipes pass them along with --recipes and it will override the run list (not the attributes!)
    LONGDESC
    def provision(targetdir='/opt')
      logo
      pid = Process.fork do
        dorun "while true; do sudo -n true; sleep 60; kill -0 \"$$\" || exit; done 2>/dev/null"
      end
      Process.detach pid
      prepare_folders(targetdir)
      install_bundler(targetdir)
      recipes = parse_config(targetdir)
      fetch_cookbooks(targetdir, options[:debug]) unless options['no-fetch']
      run_chef(targetdir, (options[:recipes] ? options[:recipes] : recipes), options[:solorb], options[:debug])
      cleanup(targetdir, options[:debug])
      Process.kill(9, pid)
      print_notice('Installation complete!')
    end

    no_commands do

      def run_chef(targetdir, recipes, solo_rb, debug=false)
        inside("#{targetdir}/kitchenplan") do
          dorun "sudo vendor/bin/chef-solo #{( debug ? ' --log_level debug' : ' ' )} -c #{solo_rb} -j tmp/kitchenplan-attributes.json -o #{recipes.join(',')}"
        end
      end

      def fetch_cookbooks(targetdir,debug=false)
        print_step('Fetch the chef cookbooks')
        inside("#{targetdir}/kitchenplan") do
          if File.exists?('vendor/cookbooks')
            dorun "vendor/bin/librarian-chef update #{( debug ? ' ' : '2>&1 > /dev/null' )}"
          else
            dorun "vendor/bin/librarian-chef install --clean #{( debug ? ' ' : '--quiet' )} --path=vendor/cookbooks"
          end
        end
      end

      def cleanup(targetdir,debug=false)
        unless debug
          print_step('Cleanup parsed configuration files')
          inside("#{targetdir}/kitchenplan") do
            dorun('rm -f kitchenplan-attributes.json')
            dorun('rm -f solo.rb')
          end
        else
            print_step('Skipping cleanup parsed configuration files')
        end
      end

      def parse_config(targetdir)
        print_step('Compiling configurations')
        require 'json'
        require 'kitchenplan/config'
        inside("#{targetdir}/kitchenplan") do
          config = Kitchenplan::Config.new
          dorun('mkdir -p tmp')
          File.open('tmp/kitchenplan-attributes.json', 'w') do |out|
            out.write(JSON.pretty_generate(config.config['attributes']))
          end
          File.open('tmp/solo.rb', 'w') do |out|
            out.write("cookbook_path      [ \"#{Dir.pwd}/vendor/cookbooks\" ]\n")
            out.write("ssl_verify_mode :verify_peer")
          end
          return config.config['recipes']
        end
      end

      def fetch(gitrepo, targetdir)
        prepare_folders(targetdir)
        if system("cd #{File.join(targetdir, 'kitchenplan')} && git remote -v | grep origin")
          print_step "#{targetdir}/kitchenplan already exists, updating from git."
          inside("#{targetdir}/kitchenplan") do
            dorun('git pull -q')
            dorun('git submodule update')
          end
        else
          print_step "Fetching #{gitrepo} to #{targetdir}/kitchenplan."
          inside("#{targetdir}") do
            dorun("git clone -q #{gitrepo} kitchenplan")
            inside("#{targetdir}/kitchenplan") do
              dorun('git submodule init')
              dorun('git submodule update')
            end
          end
        end
      end

      def create(targetdir)
        print_failure "#{targetdir}/kitchenplan already exists, please remove it before continuing." if File.exists?("#{targetdir}/kitchenplan")
        prepare_folders(targetdir)

        print_step('Creating the config folder structure')
        inside(targetdir) do
          dorun('mkdir -p kitchenplan')
        end
        inside("#{targetdir}/kitchenplan") do
          dorun('mkdir -p config')
        end
        inside("#{targetdir}/kitchenplan/config") do
          dorun('mkdir -p groups')
          dorun('mkdir -p people')
        end

        print_step('Creating the template config files')
        template('README.md.erb', "#{targetdir}/kitchenplan/README.md")
        template('default.yml.erb', "#{targetdir}/kitchenplan/config/default.yml")
        template('groupa.yml.erb', "#{targetdir}/kitchenplan/config/groups/groupa.yml")
        template('groupb.yml.erb', "#{targetdir}/kitchenplan/config/groups/groupb.yml")
        template('user.yml.erb', "#{targetdir}/kitchenplan/config/people/#{ENV['USER']}.yml")

        print_step('Preparing the Cookbook configuration')
        template('Cheffile.erb', "#{targetdir}/kitchenplan/Cheffile")

        print_step('Setting up the git repo')
        template('gitignore.erb', "#{targetdir}/kitchenplan/.gitignore")
        inside("#{targetdir}/kitchenplan") do
          dorun('git init -q')
          dorun('git add -A .')
          dorun("git commit -q -m 'Clean installation of the Kitchenplan configs for user #{ENV['USER']}'")
        end

        print_notice("Now start editing the config files in #{targetdir}/kitchenplan/config, push them to a git server and run 'kitchenplan provision'")
      end

      def create_user(targetdir)
        print_step("Creating #{ENV['USER']}.yml config")

        template('user.yml.erb', "#{targetdir}/kitchenplan/config/people/#{ENV['USER']}.yml")

        inside("#{targetdir}/kitchenplan") do
          dorun("git add -A config/people/#{ENV['USER']}.yml")
          dorun("git commit -q -m 'Initial commit for user #{ENV['USER']}'")
        end

        print_notice("Now start editing #{ENV['USER']}.yml in #{targetdir}/kitchenplan/config/people, and push it to a git server and run 'kitchenplan provision'")
      end

      def install_bundler(targetdir)
        print_step('Setting up bundler')
        template('Gemfile.erb', "#{targetdir}/kitchenplan/Gemfile")
        inside("#{targetdir}/kitchenplan") do
          dorun('mkdir -p vendor/cache')
          dorun('sudo gem install bundler --no-rdoc --no-ri') unless Kernel.system "gem query --name-matches '^bundler$' --installed > /dev/null 2>&1"
          dorun('rm -rf vendor/bundle/config')
          dorun('ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future bundle install --quiet --binstubs vendor/bin --path vendor/bundle')
        end
      end

      def install_clt
        print_step('Installing XCode CLT')
        osx_ver = dorun('sw_vers -productVersion | awk -F "." \'{print $2}\'', true).to_i
        if osx_ver >= 9
          dorun('touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress')
          prod = dorun('$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" \'{print $2}\' | sed -e \'s/^ *//\' | tr -d \'\n\')', true)
          dorun("softwareupdate -i #{prod.chomp} -v")
          dorun("rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress")
        else
          dmg = nil
          if osx_ver == 7
            dmg = 'http://devimages.apple.com/downloads/xcode/command_line_tools_for_xcode_os_x_lion_april_2013.dmg'
          elsif osx_ver == 8
            dmg = 'http://devimages.apple.com/downloads/xcode/command_line_tools_os_x_mountain_lion_for_xcode_october_2013.dmg'
          else
            print_failure('Install Xcode before continuing: https://developer.apple.com/xcode/') unless File.exists? '/usr/bin/cc'
          end
          dorun("curl \"#{dmg}\" -o \"clitools.dmg\"")
          tmpmount = dorun('/usr/bin/mktemp -d /tmp/clitools.XXXX', true).chomp
          dorun("hdiutil attach \"clitools.dmg\" -mountpoint \"#{tmpmount}\"")
          dorun("sudo installer -pkg \"$(find #{tmpmount} -name '*.mpkg')\" -target /")
          dorun("hdiutil detach \"#{tmpmount}\"")
          dorun("rm -rf \"#{tmpmount}\"")
          dorun("rm \"clitools.dmg\"")
        end
      end

      def prepare_folders(targetdir)
        print_step("Making sure #{targetdir} exists and I can write to it")
        dorun("sudo mkdir -p #{targetdir}")
        dorun("sudo chown -R #{ENV['USER']} #{targetdir}")
      end

      def dorun(command, capture=false)
        status = run(command.chomp, :capture => capture)
        if capture
          return status
        end
        unless status
          exit 1
        end
      end

      def self.source_root
        File.dirname(File.dirname(File.dirname(__FILE__))) + '/templates'
      end

      def logo
        say '  _  ___ _       _                      _             ', :yellow, true
        say ' | |/ (_) |     | |                    | |            ', :yellow, true
        say ' | \' / _| |_ ___| |__   ___ _ __  _ __ | | __ _ _ __  ', :yellow, true
        say ' |  < | | __/ __| \'_ \ / _ \ \'_ \| \'_ \| |/ _` | \'_ \ ', :yellow, true
        say ' | . \| | || (__| | | |  __/ | | | |_) | | (_| | | | |', :yellow, true
        say ' |_|\_\_|\__\___|_| |_|\___|_| |_| .__/|_|\__,_|_| |_|', :yellow, true
        say '                                 | |                  ', :yellow, true
        say '                                 |_|                  ', :yellow, true
        say '                                                      ', :yellow, true
      end

      def print_step(description)
        say "-> #{description.chomp}", :green, true
      end

      def print_notice(command)
        say "=> #{command.chomp}", :blue, true
      end

      def print_failure(error)
        say "!! FAILED: #{error.chomp}", :red, true
        exit 1
      end

      def print_warning(warning)
        say "=> WARNING: #{warning.chomp}", :yellow, true
      end
    end


  end
end
