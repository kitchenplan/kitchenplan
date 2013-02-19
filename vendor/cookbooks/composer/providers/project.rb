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
  execute "install-composer-packages" do
    only_if "which composer >>/dev/null"
    not_if "test -f #{new_resource.project_dir}/composer.lock"
    cwd new_resource.project_dir
    dev = new_resource.dev ? "--dev" : ''
    command "composer install -n -o --no-ansi #{dev}"
  end
end
action :update do
  execute "update-composer-packages" do
    only_if "which composer >>/dev/null"
    cwd new_resource.project_dir
    dev = new_resource.dev ? "--dev" : ''
    command "composer update -n -o --no-ansi #{dev}"
  end
end

action :dump_autoload do
  execute "dump-composer-autoload" do
    only_if "which composer >>/dev/null"
    cwd new_resource.project_dir
    dev = new_resource.dev ? "--dev" : ''
    command "composer update -n -o --no-ansi #{dev}"
  end
end
