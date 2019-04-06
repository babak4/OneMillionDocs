sudo cp /tmp/monitoring-agents/influxdb.repo /etc/yum.repos.d/influxdb.repo
sudo yum install -y influxdb
sudo systemctl enable influxdb
sudo systemctl start influxdb
sudo cp /tmp/monitoring-agents/grafana.repo /etc/yum.repos.d/grafana.repo
sudo yum install -y grafana
sudo systemctl enable grafana-server.service
curl -XPOST "http://localhost:8086/query" --data-urlencode 'q=CREATE DATABASE "telegraf"'
curl -XPOST "http://localhost:8086/query" --data-urlencode "q=CREATE USER admin WITH PASSWORD 'admin' WITH ALL PRIVILEGES"
sudo rm /etc/grafana/provisioning/datasources/*
sudo cp /tmp/monitoring-agents/datasource.yaml /etc/grafana/provisioning/datasources/datasource.yaml
sudo systemctl start grafana-server.service
