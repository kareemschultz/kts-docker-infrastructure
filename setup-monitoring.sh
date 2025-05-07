# Create the main directory structure
mkdir -p monitoring-stack/speedtest-tracker/config
mkdir -p monitoring-stack/speedtest-tracker/ssl-keys
mkdir -p monitoring-stack/config/prometheus
mkdir -p monitoring-stack/config/loki
mkdir -p monitoring-stack/config/promtail

# Navigate to the main directory
cd monitoring-stack

# Create the Docker Compose file
cat > docker-compose.yml << 'EOF'
version: '3'

services:
    speedtest-tracker:
        image: lscr.io/linuxserver/speedtest-tracker:latest
        restart: unless-stopped
        container_name: speedtest-tracker
        ports:
            - 8080:80
            - 8443:443
        environment:
            - PUID=1000
            - PGID=1000
            - APP_KEY=
            - DB_CONNECTION=pgsql
            - DB_HOST=db
            - DB_PORT=5432
            - DB_DATABASE=speedtest_tracker
            - DB_USERNAME=speedtest_tracker
            - DB_PASSWORD=password
        volumes:
            - ./speedtest-tracker/config:/config
            - ./speedtest-tracker/ssl-keys:/config/keys
        depends_on:
            - db
        labels:
            - "prometheus.io/scrape=true"
            - "prometheus.io/port=80"
    
    db:
        image: postgres:17
        restart: always
        container_name: postgres
        environment:
            - POSTGRES_DB=speedtest_tracker
            - POSTGRES_USER=speedtest_tracker
            - POSTGRES_PASSWORD=password
        volumes:
            - speedtest-db:/var/lib/postgresql/data
        healthcheck:
            test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
            interval: 5s
            retries: 5
            timeout: 5s
    
    influxdb:
        image: influxdb:2.7
        restart: unless-stopped
        container_name: influxdb
        ports:
            - 8086:8086
        environment:
            - DOCKER_INFLUXDB_INIT_MODE=setup
            - DOCKER_INFLUXDB_INIT_USERNAME=admin
            - DOCKER_INFLUXDB_INIT_PASSWORD=password
            - DOCKER_INFLUXDB_INIT_ORG=my-org
            - DOCKER_INFLUXDB_INIT_BUCKET=speedtest-tracker
            - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-super-secret-admin-token
        volumes:
            - influxdb-data:/var/lib/influxdb2
        labels:
            - "prometheus.io/scrape=true"
            - "prometheus.io/port=8086"
    
    prometheus:
        image: prom/prometheus:latest
        restart: unless-stopped
        container_name: prometheus
        ports:
            - 9090:9090
        volumes:
            - ./config/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
            - prometheus-data:/prometheus
        command:
            - '--config.file=/etc/prometheus/prometheus.yml'
            - '--storage.tsdb.path=/prometheus'
            - '--web.console.libraries=/etc/prometheus/console_libraries'
            - '--web.console.templates=/etc/prometheus/consoles'
            - '--web.enable-lifecycle'
    
    loki:
        image: grafana/loki:latest
        restart: unless-stopped
        container_name: loki
        ports:
            - 3100:3100
        volumes:
            - ./config/loki/loki-config.yml:/etc/loki/local-config.yaml
            - loki-data:/loki
        command: -config.file=/etc/loki/local-config.yaml
    
    promtail:
        image: grafana/promtail:latest
        restart: unless-stopped
        container_name: promtail
        volumes:
            - ./config/promtail/promtail-config.yml:/etc/promtail/config.yml
            - /var/log:/var/log
            - /var/lib/docker/containers:/var/lib/docker/containers:ro
        command: -config.file=/etc/promtail/config.yml
    
    uptime-kuma:
        image: louislam/uptime-kuma:latest
        restart: unless-stopped
        container_name: uptime-kuma
        ports:
            - 3001:3001
        volumes:
            - uptime-kuma-data:/app/data
        healthcheck:
            test: wget --no-verbose --tries=1 --spider http://localhost:3001/api/health || exit 1
            interval: 60s
            retries: 5
            timeout: 5s
    
    grafana:
        image: grafana/grafana:latest
        restart: unless-stopped
        container_name: grafana
        ports:
            - 3000:3000
        environment:
            - GF_SECURITY_ADMIN_USER=admin
            - GF_SECURITY_ADMIN_PASSWORD=password
            - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-piechart-panel,grafana-worldmap-panel
        volumes:
            - grafana-data:/var/lib/grafana
        depends_on:
            - influxdb
            - prometheus
            - loki

volumes:
  speedtest-db:
  influxdb-data:
  prometheus-data:
  loki-data:
  grafana-data:
  uptime-kuma-data:
EOF

# Create Prometheus configuration
cat > config/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'docker'
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        filters:
          - name: label
            values: ['prometheus.io/scrape=true']
    relabel_configs:
      - source_labels: [__meta_docker_container_name]
        target_label: container_name
      - source_labels: [__meta_docker_container_label_prometheus_io_port]
        target_label: __metrics_path__
        replacement: /metrics
      - source_labels: [__address__, __meta_docker_container_label_prometheus_io_port]
        target_label: __address__
        regex: '(.*):.*'
        replacement: '$1:$2'
EOF

# Create Loki configuration
cat > config/loki/loki-config.yml << 'EOF'
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/index_cache
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
EOF

# Create Promtail configuration
cat > config/promtail/promtail-config.yml << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: 'logstream'
      - source_labels: ['__meta_docker_container_label_logging_jobname']
        target_label: 'job'
EOF

# Output successful message
echo "All files and folders created successfully. Navigate to the monitoring-stack directory and run 'docker-compose up -d' to start the stack."
