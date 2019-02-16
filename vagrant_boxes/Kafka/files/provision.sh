sudo yum install -y wget java-1.8.0-openjdk.x86_64
sudo useradd kafka -m
sudo echo "kafka" | passwd kafka --stdin
sudo usermod -aG wheel kafka
cd /tmp
sudo cp zookeeper.service /etc/systemd/system
sudo cp kafka.service /etc/systemd/system
wget http://apache.mirror.anlx.net/kafka/2.1.0/kafka_2.11-2.1.0.tgz
su kafka -c 'mkdir /home/kafka/kafka'
su kafka -c 'cd /home/kafka/kafka'
echo "unzipping kafka..."
su kafka -c 'tar -xvzf /tmp/kafka_2.11-2.1.0.tgz -C /home/kafka/kafka --strip-components=1'
su kafka -c 'echo -e "\ndelete.topic.enable = true" >> ~/kafka/config/server.properties'
sudo systemctl stop firewalld
sudo systemctl start kafka
sudo systemctl enable kafka
echo "waiting for 10 seconds for the broker to start up"
sleep 10
echo "creating TestTopic"
su kafka -c '~/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic TestTopic'