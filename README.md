# Network Boot Setup - iPXE Infrastructure

[![Dell](https://img.shields.io/badge/Dell%20PowerEdge-blue?style=for-the-badge&logo=dell&logoColor=white)](https://www.dell.com/support/kbdoc/en-us/000134115)
[![Ubiquiti](https://img.shields.io/badge/Ubiquiti-Dream%20Machine-0559C9?style=for-the-badge&logo=ubiquiti&logoColor=white)](https://ui.com/)
[![iPXE](https://img.shields.io/badge/iPXE-UEFI-green?style=for-the-badge&logo=boot&logoColor=white)](https://ipxe.org/)
[![Fedora CoreOS](https://img.shields.io/badge/Fedora%20CoreOS-51A2DA?style=for-the-badge&logo=fedora&logoColor=white)](https://getfedora.org/coreos/)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/Astocanthus/low-layer-tftpboot.svg)](https://github.com/Astocanthus/low-layer-tftpboot/releases)
[![GitHub issues](https://img.shields.io/github/issues/Astocanthus/low-layer-tftpboot.svg)](https://github.com/Astocanthus/low-layer-tftpboot/issues)
![Dell iDRAC](https://img.shields.io/badge/Dell%20iDRAC-%3E%3D9-blue?logo=dell)

## Overview

Complete network boot infrastructure using iPXE for automated OS deployment on Dell PowerEdge servers (R340/R740). The setup provides PXE boot capabilities with automated installation through network infrastructure using Ubiquiti routing and Dell iDRAC management.

## Infrastructure Components

**Hardware**: Dell PowerEdge R340 and R740 servers with iDRAC, Ubiquiti router for DHCP/routing, UEFI boot environment with iPXE support.

**Core Files**: `autoexec.ipxe` main boot script with automated menu and OS selection, `ipxe.efi` UEFI-compatible bootloader binary.

## autoexec.ipxe Script

The main iPXE script handles automated boot menu with multiple OS installation options, hardware detection for appropriate OS selection, network configuration and server communication, plus boot process automation for unattended installations. Key features include dynamic IP configuration via DHCP, multiple OS boot options (Linux distributions, Windows Server), hardware-specific boot paths for Dell servers, and error handling with retry mechanisms.

**Script Template Configuration**: The autoexec.ipxe.tpl file contains placeholder values that must be replaced with your actual server configuration:

```
<fqdn_ipxe_server>           # Replace with your iPXE server FQDN or IP
<http_user_ipxe_server>      # Replace with HTTP authentication username  
<http_password_ipxe_server>  # Replace with HTTP authentication password
```

After replacing the values, rename the file from `autoexec.ipxe.tpl` to `autoexec.ipxe` (remove the .tpl extension). The template automatically detects machine types based on hostname/asset variables and loads appropriate Ignition configurations for Fedora CoreOS deployments targeting OpenStack Controller, Compute nodes, or default installations.

**Required Images**: The script installs Fedora CoreOS using kernel, rootfs, and initramfs images that must be present on the iPXE server at `/images/fcos/` directory:
- `fedora-kernel.img` - Fedora CoreOS kernel image
- `fedora-rootfs.img` - Fedora CoreOS root filesystem image  
- `fedora-initramfs.img` - Fedora CoreOS initial RAM filesystem

## ipxe.efi Bootloader  

UEFI-compatible iPXE bootloader supporting modern UEFI boot environments, automatically loads the autoexec.ipxe script, provides network boot capabilities for UEFI systems, and maintains compatibility with Dell R340/R740 UEFI firmware.

## Network Configuration

> **⚠️ Network Recommendation**: It is preferable that the iPXE server and the target servers are connected on the same network to avoid network card configuration issues during the iPXE boot sequence.

**DHCP Configuration (Ubiquiti Router)**
The Ubiquiti router is configured to:
- Provide IP addresses to booting servers
- Deliver iPXE boot information via DHCP options
- Route traffic between management and deployment networks

Required DHCP options:
```
Option 66 (TFTP Server): [IP of boot server]
Option 67 (Boot filename): ipxe.efi
```

**Dell Server Configuration**: iDRAC >= 9 network setup for remote management with virtual media mounting and power management capabilities. BIOS/UEFI configured for network boot priority, UEFI boot mode enabled, network stack enabled for PXE functionality.

## Boot Process Flow

Server powers on and initializes hardware, UEFI firmware loads and network stack initializes interfaces. DHCP request provides IP address and boot information, server downloads ipxe.efi from TFTP/HTTP server. iPXE bootloader starts and loads autoexec.ipxe, script processes boot menu or automates selection, selected OS installer downloads and begins installation.

## Supported Systems & Automation

**Operating Systems**: Linux distributions (Ubuntu Server, CentOS, Debian, RHEL), Windows Server 2019/2022 with automated installation, hypervisor platforms (VMware ESXi, Proxmox VE), and custom organizational OS builds.

**Automation Features**: Unattended installation with predefined configurations, automatic hardware-specific driver loading, network configuration preservation, and post-installation script execution.

## Usage & Deployment

**Initial Setup**: Configure Ubiquiti router DHCP settings with boot options, setup TFTP/HTTP server for iPXE files and OS images, configure Dell iDRAC network settings, set BIOS/UEFI boot order for network priority, deploy iPXE files to boot server.
Initial configuration made by [low-layer-platform/terraform/infrastructure](https://github.com/Astocanthus/low-layer-platform/tree/main/terraform/infrastructure) terraform project.

**Deployment Process**: Power on target server (remotely via iDRAC), server automatically boots from network, iPXE menu appears with OS options, select installation or wait for auto-selection, monitor progress through iDRAC console (IPMI).

## Troubleshooting & Management

**Common Issues**: DHCP not responding (check router config), iPXE download fails (verify server accessibility), boot loops (check autoexec.ipxe syntax), installation hangs (review image integrity).

**Diagnostic Commands**:
```bash
# Test DHCP response
dhcping -s [DHCP_SERVER_IP] -c [CLIENT_IP]

# Verify TFTP server
tftp [SERVER_IP] -c get ipxe.efi

# Check network connectivity
ping [BOOT_SERVER_IP]
```

**Note**: This setup provides a scalable foundation for automated server deployments in datacenter environments. Regular testing and validation of the boot process ensures reliable automated installations.

