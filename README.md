# KTS Docker Infrastructure

A comprehensive collection of self-hosted services and infrastructure components running in Docker. This repository contains the essential configuration files for various services that make up our production infrastructure.

## Overview

This repository includes configuration for:

- Networking: WireGuard VPN, NGINX Proxy Manager, Turnserver
- Monitoring: Monitoring stack, Uptime Kuma, Speedtest Tracker  
- Notification: Gotify, ntfy
- Management: Portainer, Watchtower
- Documentation: Wiki.js
- Authentication & Identity: Zitadel
- Productivity: Nextcloud, Invoice Ninja
- Financial: Wallos
- Networking & Infrastructure: Netbox, Caddy

## Structure

Each directory typically contains the docker-compose.yml file and essential configuration, while excluding data directories, logs, and runtime files.
