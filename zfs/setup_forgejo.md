# Setup Forgejo

Assuming the ZFS pool has been setup and mounted inside the LXC forgejo will run in.

## Optimize ZFS

```sh
# In proxmox host console
# save space for text files with zstd compressions.
zfs set compression=zstd tank1/forgejo
# prevent unnecessary write operations when a file / repo is read from.
zfs set atime=off tank1/forgejo
```

## Download Forgejo

[Forgejo Debian](https://codeberg.org/forgejo-contrib/forgejo-deb).

```sh
curl https://code.forgejo.org/api/packages/apt/debian/repository.key -o /etc/apt/keyrings/forgejo-apt.asc
echo "deb [signed-by=/etc/apt/keyrings/forgejo-apt.asc] https://code.forgejo.org/api/packages/apt/debian lts main" | tee /etc/apt/sources.list.d/forgejo.list
apt update
apt install forgejo-sqlite
```

## Setup Forgejo File Locations

```sh
systemctl stop forgejo

mkdir -p /mnt/forgejo/data/forgejo-repositories
mkdir -p /mnt/forgejo/data/lfs
mkdir -p /mnt/forgejo/log
chown -R forgejo:forgejo /mnt/forgejo
```

## Setup SSH Key

```sh
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519_forgejo
cat ~/.ssh/id_ed25519_forgejo.pub
```

Edit `~/.ssh/config`.

```conf
Host my-forgejo
	HostName <IP_ADDRESS>
    Port 22 # or whatever was the setup SSH port
	User forgejo
	IdentityFile ~/.ssh/id_ed25519_forgejo
```
