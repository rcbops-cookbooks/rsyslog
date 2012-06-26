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

# find host with role single-controller and grab facility information for glance, keystone, nova.
# facility must be consistent throughout cluster.
glance_info = get_settings_by_role("glance", "glance")
glance_facility = glance_info["syslog"]["facility"] unless keystone_info["syslog"]["use_syslog"] == false
keystone_info = get_settings_by_role("keystone", "keystone")
keystone_facility = keystone_info["syslog"]["facility"] unless keystone_info["syslog"]["use_syslog"] == false
nova_info = get_settings_by_role("single-controller", "nova")
nova_facility = nova_info["syslog"]["facility"] unless nova_info["syslog"]["use_syslog"] == false

template "/etc/rsyslog.d/35-server-per-host.conf" do
  source "35-server-per-host.conf_openstack.erb"
  backup false
  variables(
    :log_dir => node['rsyslog']['log_dir'],
    :per_host_dir => node['rsyslog']['per_host_dir'],
    :nova_facility => nova_facility,
    :glance_facility => glance_facility,
    :keystone_facility => keystone_facility
  )
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[rsyslog]"
end
