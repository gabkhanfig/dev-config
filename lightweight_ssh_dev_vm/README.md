# Lightweight SSH Dev VM Setup

Using Debain

```sh
qemu-img create -f qcow2 debian_dev_vm.qcow2 128G

qemu-system-x86_64 \
-machine type=q35,accel=kvm \
-cpu host \
-smp 4 \
-m 16G \
-drive file=debian_dev_vm.qcow2,format=qcow2,if=virtio \
-cdrom debian-13.4.0-amd64-netinst.iso \
-boot d \
-netdev user,id=net0 \
-device virtio-net-pci,netdev=net0 \
-display gtk
```

## TMux Session

```sh
tmux new-session -A -s debian_dev_vm

# Boot without ISO, and with host forwarded SSH port
qemu-system-x86_64 \
-machine type=q35,accel=kvm \
-cpu host \
-smp 4 \
-m 16G \
-drive file=debian_dev_vm.qcow2,format=qcow2,if=virtio \
-netdev user,id=net0,hostfwd=tcp::49999-:22 \
-device virtio-net-pci,netdev=net0 \
-display gtk \
-serial stdio
```

Inside the VM:

```sh
sudo systemctl status ssh

# If ssh.service could not be found
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

```sh
# Connect to VM
ssh -p 49999 USER_NAME@IP_ADDR

sudo apt install git build-essential curl cmake gh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Neovim Setup

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
nano ~/.bashrc
# PASTE THE FOLLOWING INTO .bashrc
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

Detach tmux

Press CTRL + b, release, then press d.
