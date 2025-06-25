# System Hardening Module

This module provides comprehensive system hardening for both Linux and Darwin (macOS) systems.

## Features

### SSH Hardening
- Disables root login and password authentication
- Enforces strong key exchange algorithms, ciphers, and MACs
- Implements connection rate limiting and timeout settings
- Removes weak host key algorithms
- Based on recommendations from:
  - https://blog.stribik.technology/2015/01/04/secure-secure-shell.html
  - https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-20-04

### Firewall Configuration
- Enables host-based firewall (iptables/nftables on Linux, pf on macOS)
- Blocks all incoming connections by default
- Implements rate limiting for SSH
- Protects against common port scanning techniques
- Logs dropped packets for monitoring

### Kernel Hardening
- Disables unnecessary kernel modules
- Implements secure sysctl settings
- Enables kernel security features (ASLR, DEP, etc.)
- Restricts access to kernel logs and pointers
- Disables IP forwarding and source routing

### User and Permission Hardening
- Enforces secure sudo configuration
- Sets restrictive file permissions
- Implements password policies
- Disables unnecessary SUID/SGID binaries
- Configures PAM for enhanced security

### Audit and Logging
- Enables comprehensive audit logging
- Monitors sensitive file changes
- Tracks authentication attempts
- Implements fail2ban for automated blocking
- Configures centralized logging

## Usage

To enable the hardening module in your system configuration:

```nix
{ config, pkgs, ... }:

{
  imports = [
    ./modules/hardening
  ];

  systems.hardening.enable = true;
}
```

## Platform Support

- **Linux**: Full support for all hardening features
- **Darwin (macOS)**: Adapted configurations for macOS-specific security features

## Configuration

The module is designed to work out of the box with secure defaults. However, you may need to adjust some settings based on your specific requirements:

- SSH allowed users/groups
- Firewall allowed ports
- Kernel module blacklist
- Audit rules

## Testing

After enabling the module, you can verify the hardening with:

```bash
# Check SSH configuration
sshd -T

# Verify firewall rules (Linux)
iptables -L -n -v

# Verify firewall rules (macOS)
pfctl -sr

# Check kernel parameters
sysctl -a | grep -E "(net.ipv4|kernel)"

# Run security audit
lynis audit system
```

## Notes

- Some hardening measures may impact system functionality
- Test thoroughly in a non-production environment first
- Review logs regularly for security events
- Keep the system and security tools updated