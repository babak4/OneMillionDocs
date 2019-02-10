cd /tmp
sudo cp mongodb-org-4.0.repo /etc/yum.repos.d/mongodb-org-4.0.repo
sudo yum install -y mongodb-org
sudo cp mongod.conf /etc/mongod.conf
sudo service mongod start


