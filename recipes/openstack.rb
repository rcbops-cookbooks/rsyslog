#
# Cookbook Name:: glance
# Recipe:: default
#
# Copyright 2009, Rackspace Hosting, Inc.
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

template "/etc/rsyslog.d/35-server-per-host.conf" do
  source "35-server-per-host.conf_openstack.erb"
  backup false
  variables(
    :log_dir => node['rsyslog']['log_dir'],
    :per_host_dir => node['rsyslog']['per_host_dir'],
    :nova_facility => node['nova']['syslog']['facility'] unless node['nova']['syslog']['use'] == false,
    :glance_facility => node['glance']['syslog']['facility'] unless node['glance']['syslog']['use'] == false,
    :keystone_facility => node['keystone']['syslog']['facility'] unless node['keystone']['facility']['use'] == false
  )
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[rsyslog]"
end
