sudo cp /tmp/influxdb.repo /etc/yum.repos.d/influxdb.repo
sudo yum install -y telegraf
sudo cp /tmp/mongodb-org-4.0.repo /etc/yum.repos.d/mongodb-org-4.0.repo
sudo yum install -y mongodb-org
sudo cp /tmp/mongod.conf /etc/mongod.conf
sudo service mongod start
sudo cp /tmp/telegraf.conf /etc/telegraf/telegraf.conf
sudo systemctl enable telegraf
sudo systemctl start telegraf


