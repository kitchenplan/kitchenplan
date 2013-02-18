action :install do
  git ::File.expand_path(new_resource.name, new_resource.destination) do
    repository new_resource.source
    user new_resource.owner
    action :sync
  end

  new_resource.updated_by_last_action(true)
end
