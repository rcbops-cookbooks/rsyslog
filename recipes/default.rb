#
# Cookbook Name:: rsyslog
# Recipe:: default
#
# Copyright 2009-2011, Opscode, Inc.
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

platform_options = node["rsyslog"]["platform"]

apt_repository "hardy-rsyslog-ppa" do
  uri "http://ppa.launchpad.net/a.bono/rsyslog/ubuntu"
  distribution "hardy"
  components ["main"]
  keyserver "hkp://keyserver.ubuntu.com:80"
  key "C0061A4A"
  action :add
  #notifies :run, "execute[apt-get update]", :immediately
  only_if { platform?("ubuntu") && node['platform_version'].to_f == 8.04 }
end

package "rsyslog" do
  action :install
end

case node['platform']
  when "debian", "ubuntu"

    user "syslog" do
      username platform_options["rsyslog_user"]
      home "/home/syslog"
      shell "/bin/false"
      system true
      action :create
    end

    cookbook_file "/etc/default/rsyslog" do
      source "rsyslog.default"
      owner "root"
      group "root"
      mode 0644
    end

  end

directory "/etc/rsyslog.d" do
  owner "root"
  group "root"
  mode 0755
end

directory "/var/spool/rsyslog" do
  owner platform_options["rsyslog_user"]
  group platform_options["rsyslog_group"]
  mode 0755
end

template "/etc/rsyslog.d/50-default.conf" do
  source "50-default.conf.erb"
  backup false
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[rsyslog]", :delayed
end

template "/etc/rsyslog.conf" do
  source "rsyslog.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(:protocol => node['rsyslog']['protocol'])
  notifies :restart, "service[rsyslog]", :immediately
end


service "rsyslog" do
  service_name "rsyslogd" if platform?("arch")
  supports :reload=> true, :reload => true
  action [:enable, :start]
end
