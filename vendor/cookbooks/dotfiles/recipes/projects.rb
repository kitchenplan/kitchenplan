
node['dotfiles']['projects'].each do |folder, repohash|

    directory "#{node['etc']['passwd'][node['current_user']]['dir']}/Development/#{folder}" do
        owner node['current_user']
    end

    repohash.each do |repos|
        repos.each do |repo|
            git "#{node['etc']['passwd'][node['current_user']]['dir']}/Development/#{folder}/#{repo[0]}" do
                repository repo[1]
                enable_submodules true
                action :checkout
                user node['current_user']
            end
        end
    end

end
