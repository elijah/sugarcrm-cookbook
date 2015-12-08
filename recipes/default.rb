#
# Cookbook Name:: sugarcrm
# Recipe:: default
#
# Copyright 2011, SugarCRM
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


include_recipe "apache2"
include_recipe %w{php::package php::module_mysql}
include_recipe "git"

#include_recipe 'mysql2_chef_gem'
package "libmysqlclient-dev"

mysql_client 'default' do
  action :create
end

chef_gem "mysql2"

mysql_service 'sugarcrm-mysql' do
  port '3306'
  version '5.5'
  initial_root_password "#{node['sugarcrm']['db']['password']}"
  action [:create, :start]
end

# Create a mysql database
mysql_database 'sugarcrm' do
  connection(
    :host     => '127.0.0.1',
    :username => 'root',
    :password => node['sugarcrm']['db']['password']
  )
  action :create
end

# Externalize conection info in a ruby hash
mysql_connection_info = {
  :host     => '127.0.0.1',
  :username => 'root',
  :password => "#{node['sugarcrm']['db']['password']}"
  #node['mysql']['server_root_password']
}

# grant select,update,insert privileges to all tables in foo db from all hosts, requiring connections over SSL
mysql_database_user 'sugarcrm' do
  connection mysql_connection_info
  password 'super_secret'
  database_name 'foo'
  host '%'
  privileges [:select,:update,:insert]
  require_ssl true
  action :grant
end

directory "#{node[:sugarcrm][:webroot]}" do
  owner "#{node[:apache][:user]}"
  group "#{node[:apache][:group]}"
  recursive true
  action :create
end

git "#{node[:sugarcrm][:webroot]}" do
  repository "git://github.com/sugarcrm/sugarcrm_dev.git"
  user "#{node[:apache][:user]}"
  group "#{node[:apache][:group]}"
  reference "master"
  action :checkout
end

template "config_si.php" do
  source "config_si.php.erb"
  path "#{node[:sugarcrm][:webroot]}/config_si.php"
  owner "#{node[:apache][:user]}"
  group "#{node[:apache][:group]}"
end

cron "sugarcron" do
  minute "*/2"
  command "/usr/bin/php -f #{node[:sugarcrm][:webroot]}/cron.php >> /dev/null"
  user "#{node[:apache][:user]}"
end
