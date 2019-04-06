sudo systemctl stop firewalld
sudo setsebool -P httpd_can_network_connect_db 1
sudo setenforce 0

sudo cp /tmp/influxdb.repo /etc/yum.repos.d/influxdb.repo
sudo yum install -y telegraf
sudo cp /tmp/telegraf.conf /etc/telegraf/telegraf.conf
sudo systemctl enable telegraf
sudo systemctl start telegraf


