#!ipxe

set server <fqdn_ipxe_server>
set username <http_user_ipxe_server>
set password <http_password_ipxe_server>

ifclose
ifopen net0
dhcp net0
ifstat
show dns

# Select Host type from FQDN/hostname
iseq ${asset} OpenstackController && goto machine-controller ||
iseq ${asset} OpenstackComputer && goto machine-compute ||
goto machine-default

:machine-controller
set ignition_url http://${username}:${password}@${server}/ignition/os-controller.ign
echo Openstack Controller config loaded
goto boot

:machine-compute
set ignition_url http://${username}:${password}@${server}/ignition/os-computer.ign
echo Openstack Computer config loaded
goto boot

:machine-default
set ignition_url http://${username}:${password}@${server}/ignition/default.ign
echo Default config loaded
goto boot

:boot
# Chargement du kernel
kernel http://${username}:${password}@${server}/images/fcos/fedora-kernel.img \
    initrd=main \
    ip=dhcp \
    ignition.platform.id=metal \
    ignition.firstboot \
    coreos.inst.install_dev=/dev/sda \
    coreos.live.rootfs_url=http://${username}:${password}@${server}/images/fcos/fedora-rootfs.img \
    coreos.inst.ignition_url=${ignition_url}

# Chargement de l'initramfs
initrd --name main http://${username}:${password}@${server}/images/fcos/fedora-initramfs.img

sleep 30
# Démarrage
boot