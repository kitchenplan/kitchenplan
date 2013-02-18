def load_current_resource
    @tap = Chef::Resource::HomebrewTap.new(new_resource.name)
    tap_dir = @tap.name.gsub('/', '-')

    Chef::Log.debug("Checking whether we've already tapped #{new_resource.name}")
    if ::File.directory?("/usr/local/Library/Taps/#{tap_dir}")
      @tap.tapped true
    else
      @tap.tapped false
    end
end

action :tap do
    execute "tapping #{new_resource.name}" do
        command "/usr/local/bin/brew tap #{new_resource.name}"
        not_if { @tap.tapped }
    end
    new_resource.updated_by_last_action(true)
end

action :untap do
    execute "untapping #{new_resource.name}" do
      command "/usr/local/bin/brew untap #{new_resource.name}"
      only_if { @tap.tapped }
    end
    new_resource.updated_by_last_action(true)
end
