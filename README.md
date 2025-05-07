# 🐳 KTS Docker Infrastructure

A comprehensive collection of self-hosted services and infrastructure components running in Docker. This repository contains the essential configuration files for our production infrastructure.

## 📋 Overview

This repository provides a centralized location for managing the Docker-based services that power our infrastructure. By using containerization, we ensure consistent deployment, easier maintenance, and better resource utilization across our environments.

## 🚀 Services

### 🔐 Security & Access
- **WireGuard WG Easy** - Simple VPN solution with web UI
- **Zitadel** - Identity and Access Management
- **MachineKey** - Security keys and token management

### 🌐 Networking
- **NGINX Proxy Manager** - Reverse proxy and SSL management
- **Caddy** - Modern web server with automatic HTTPS
- **Turnserver** - WebRTC TURN/STUN server
- **Netbox** - IP address management (IPAM) and DCIM tool

### 📊 Monitoring
- **Monitoring Stack** - Prometheus, Grafana, and alerting
- **Uptime Kuma** - Uptime monitoring with status page
- **Speedtest Tracker** - Internet connection monitoring

### 📱 Notification
- **Gotify** - Self-hosted push notification service
- **ntfy** - Simple HTTP-based pub-sub notification service

### 🧰 Management
- **Portainer** - Docker management UI
- **Watchtower** - Automatic Docker container updates

### 📝 Documentation & Productivity
- **Wiki.js** - Modern and powerful wiki platform
- **Nextcloud** - File sharing and collaboration platform
- **Invoice Ninja** - Invoicing and billing platform

### 💰 Financial
- **Wallos** - Subscription management and tracking

### 🔧 Other Services
- **MendyFi Hotspot** - Hotspot management
- **Pangolin** - Custom service

## 🗂️ Directory Structure

```
.
├── Caddyfile                    # Caddy web server configuration
├── docker-compose.yml           # Main docker-compose file
├── gotify/                      # Notification service
├── invoiceninja/                # Invoicing and billing platform
├── machinekey/                  # Security keys and tokens
├── mendyfi-hotspot/             # Hotspot management service
├── monitoring-stack/            # Monitoring services
├── netbox/                      # IP address management tool
├── nextcloud/                   # File sharing platform
├── nginx-proxy-manager/         # Reverse proxy management
├── ntfy/                        # Push notification service
├── pangolin/                    # Custom service
├── portainer/                   # Docker management UI
├── uptime-kuma/                 # Uptime monitoring
├── wallos/                      # Financial management
├── watchtower/                  # Automatic Docker updates
├── wikijs/                      # Wiki platform
└── wireguard-wg-easy/           # VPN service with web UI
```

## 🔧 Installation & Setup

### Prerequisites

- Docker Engine (v20.10+)
- Docker Compose (v2.0+)
- Git
- At least 4GB RAM and 20GB disk space (recommended)

### Getting Started

1. **Clone this repository**:
   ```bash
   git clone https://github.com/kareemschultz/kts-docker-infrastructure.git
   cd kts-docker-infrastructure
   ```

2. **Configure environment variables**:
   - Review and modify any `.env` files for various services
   - Set proper domain names in the Caddyfile

3. **Start all services**:
   ```bash
   docker-compose up -d
   ```

   Or start individual stacks:
   ```bash
   cd monitoring-stack
   docker-compose up -d
   ```

## 🛠️ Maintenance

### Backups

Important data is stored in Docker volumes. It's recommended to implement a backup strategy for these volumes:

```bash
# Example backup command for a volume
docker run --rm -v kts_portainer_data:/source -v /backup:/backup \
  busybox tar -czf /backup/portainer-backup-$(date +%Y%m%d).tar.gz -C /source .
```

### Updates

Most services are updated automatically through Watchtower, but check individual service documentation for specific update procedures.

## 🔒 Security Notes

- Security credentials are stored in `.env` files and should be properly secured
- The `machinekey` directory contains sensitive information and is not tracked in git
- Consider using Docker secrets for production deployments

## 🌟 Key Features

- **Centralized Management**: All services managed from a single repository
- **Scalable Architecture**: Easy to add or remove services as needed
- **Automated Updates**: Watchtower keeps containers up-to-date
- **Networking Isolation**: Services organized with proper network segregation
- **Monitoring & Alerting**: Comprehensive monitoring setup

## 📚 Documentation

Each service has its own directory with a docker-compose.yml file and necessary configuration files. For more detailed documentation:

- Check the official documentation for each service
- Refer to the README files in individual service directories
- Use Portainer for a visual overview of running containers

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- All the open-source projects included in this infrastructure
- Docker and the containerization community
- The self-hosted community for inspiration and guides
