# Setup ZFS Pool For an LXC

This document will only outline the proxmox setup.

## Identify the Disks

```sh
# In proxmox host console

ls -l /dev/disk/by-id/
lbslk -o NAME,SIZE,MODEL,SERIAL
```

## Create Pool

Use `compatibility=openzfs-2.1` so that importing it on another system later is unlikely to encounter incompatibility issues.

```sh
# In proxmox host console

# Create duplicated pool
zpool create -o compatibility=openzfs-2.1 <POOL_NAME> mirror /dev/disk/by-id/<FIRST_DISK_ID_HERE> /dev/disk/by-id/<SECOND_DISK_ID_HERE>

# Create striped pool
zpool create -o compatibility=openzfs-2.1 <POOL_NAME> raidz /dev/disk/by-id/<FIRST_DISK_ID_HERE> /dev/disk/by-id/<SECOND_DISK_ID_HERE> /dev/disk/by-id/<THIRD_DISK_ID_HERE>
```

## Create Datasets

You can create datasets within a pool to isolate what has access to what.

```sh
# In proxmox host console
zfs create <POOL_NAME>/<DATASET_NAME>

# Setup ownership
chown -R 100000:100000 <POOL_NAME>/<DATASET_NAME>

# Examples
zfs create tank1/forgejo
zfs create tank1/nextcloud
zfs create tank1/garage
zfs create tank1/files # samba perhaps
zfs create tank1/files/shared
zfs create tank1/files/personal
```

## Bind Mount Datasets For LXC

```sh
# In proxmox host console
nano /etc/pve/lxc/<LXC_ID>.conf
```

```conf
mp0: /<POOL_NAME>/<DATASET_NAME>,mp=/mnt/<DATASET_NAME>

# Examples
mp1: /tank1/forgejo,mp=/mnt/forgejo
mp1: /tank1/nextcloud,mp=/mnt/nextcloud
mp2: /tank1/garage,mp=/mnt/garage
mp3: /tank1/files/personal,mp=/mnt/files/personal
```

## Samba Setup

```conf
# smb.conf

[global]
   workgroup = WORKGROUP
   security = user
   map to guest = never

[personal]
   path = /mnt/files/personal
   valid users = youruser
   read only = no
   browseable = yes
```

### Adding Samba Users

```sh
# Inside LXC

chmod 770 /mnt/files/personal && chown youruser:youruser /mnt/files/personal
chmod 770 /mnt/files/some_user && chown some_user:some_user /mnt/files/some_user
chmod 1770 /mnt/files/shared && chown youruser:users /mnt/files/shared

# Add users
# No home directory and no shell login
useradd -M -s /sbin/nologin some_user
# Set their SMB password
smbpasswd -a some_user
```

And modify the `smb.conf`.

```conf
# smb.conf

[global]
   workgroup = WORKGROUP
   security = user
   map to guest = never

[personal]
   path = /mnt/files/personal
   valid users = youruser
   read only = no
   browseable = yes

[some_user]
   path = /mnt/files/some_user
   valid users = some_user
   read only = no
   browseable = yes

[shared]
   path = /mnt/files/shared
   valid users = youruser some_user
   read only = no
   browseable = yes
```
