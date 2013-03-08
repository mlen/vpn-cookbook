require 'ipaddr'

include_recipe "ferm"
include_recipe "sysctl"

defaults = node['vpn']

raise "Please set up node['vpn']['psk'] before proceeding..." if defaults['psk'].nil?

# calculate IP ranges for VPN
network = IPAddr.new defaults['network']
network = network.mask defaults['netmask']
range   = network.to_range
range   = range.take(range.count - 2).drop(1)
first, last, local = range.first, range.last, range.last.succ

package "openswan"
package "xl2tpd"

# forward definitions
service "ipsec"
service "xl2tpd"

template "/etc/ppp/pap-secrets" do
  owner "root"
  group "root"
  mode  "0600"

  source "pap-secrets.erb"
  notifies :restart, "service[xl2tpd]"
end

template "/etc/ppp/xl2tpd" do
  owner "root"
  group "root"
  mode  "0644"

  source "xl2tpd-options.erb"
  variables :dns_servers => defaults['dns'], :netmask => defaults['netmask']
  notifies :restart, "service[xl2tpd]"
end

template "/etc/xl2tpd/xl2tpd.conf" do
  owner "root"
  group "root"
  mode  "0644"

  source "xl2tpd.conf.erb"
  variables :first => first, :last => last, :local => local
  notifies :restart, "service[xl2tpd]"
end

template "/etc/ipsec.conf" do
  owner "root"
  group "root"
  mode  "0644"

  source "ipsec.conf.erb"
  variables :server => node['ipaddress']
  notifies :restart, "service[ipsec]"
end

template "/etc/ipsec.secrets" do
  owner "root"
  group "root"
  mode  "0600"

  source "ipsec.secrets.erb"
  variables :server => node['ipaddress'], :psk => defaults['psk']
  notifies :restart, "service[ipsec]"
end

firewall_include "vpn" do
  variables :network => defaults['network'], :netmask => defaults['netmask']
end

sysctl "vpn settings" do
  settings "net.ipv4" => {
    "conf" => {
      "all" => {
        "send_redirects" => 0,
        "log_martians" => 0,
        "rp_filter" => 0,
        "accept_redirects" => 0
      },
      "default" => {
        "send_redirects" => 0,
        "log_martians" => 0,
        "rp_filter" => 0,
        "accept_redirests" => 0,
        "accept_source_route" => 0
      }
    },
    "ip_forward" => 1,
    "icmp_ignore_bogus_error_responses" => 1
  }
end

service "xl2tpd" do
  priority 18
  supports :restart => true
  notifies :restart, "service[ipsec]"
  action [:enable, :start]
end

service "ipsec" do
  priority 19
  supports :restart => true, :reload => true, :status => true
  action [:enable, :start]
end

