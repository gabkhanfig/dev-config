# Setup Tailscale

## Get Curl

```sh
apt install curl
```

## Get Tailscale

```sh
curl -fsSL https://tailscale.com/install.sh | sh
```

## VPN Network Device

Ensure `/dev/net/tun` is passed through in LXC resources.
