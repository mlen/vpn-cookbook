# IPsec/L2TP cookbook for Chef

Installs and configures OpenSwan/xl2tpd VPN.

## Requirements

* `ferm` cookbook from mlen/ferm-cookbook
* `sysctl` cookbook from vpslab/sysctl-cookbook

## Configuration

You have to configure the `psk` parameter (this is the pre-shared key for the
VPN). Defining `dns` servers is also a good idea. Network/netmask values are
sane defaults.

    default['vpn'] = {
      'psk'     => nil,
      'dns'     => [],
      'network' => '192.168.5.0',
      'netmask' => '255.255.255.0'
    }

