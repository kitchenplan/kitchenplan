#
# Cookbook Name:: composer
#
# Copyright 2012, Robert Allen
#
# @license    http://www.apache.org/licenses/LICENSE-2.0
#             Copyright [2012] [Robert Allen]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
action :install do
  remote_file "get-composer" do
    not_if "test -f #{new_resource.install_path}/composer.phar"
    path "#{new_resource.install_path}/composer.phar"
    source "https://getcomposer.org/composer.phar"
    owner new_resource.owner
    mode 0755
  end
  execute "ln -nsf #{new_resource.install_path}/composer.phar #{new_resource.install_path}/composer"
end

action :uninstall do
  execute "unalias-composer" do
    only_if "test -f /etc/profile.d/composer.sh"
    command "unalias composer;rm -f /etc/profile.d/composer.sh"
  end
  execute "uninstall-composer" do
    only_if "test -f #{new_resource.install_path}/composer.phar"
    command "rm -f #{new_resource.install_path}/composer.phar"
  end
end

action :update do
  execute "self-update-composer" do
    only_if "test -f #{new_resource.install_path}/composer.phar"
    command "#{new_resource.install_path}/composer.phar -n --no-ansi self-update"
  end
end
