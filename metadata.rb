name             "vpn"
maintainer       "Mateusz Lenik"
maintainer_email "mt.lenik@gmail.com"
license          "WTFPL"
description      "Installs and configures IPsec/L2TP VPN"
version          "1.0.3"

recipe "vpn", "Installs and configures VPN server"

depends "sysctl"

supports "debian"

