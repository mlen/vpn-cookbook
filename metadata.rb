name             "vpn"
maintainer       "Mateusz Lenik"
maintainer_email "mt.lenik@gmail.com"
license          "WTFPL"
description      "Installs and configures IPsec/L2TP VPN"
version          "1.0.2"

recipe "vpn", "Installs and configures VPN server"

depends "ferm"
depends "sysctl"

supports "debian"

