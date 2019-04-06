sudo cp /tmp/mongodb-org-4.0.repo /etc/yum.repos.d/mongodb-org-4.0.repo
sudo yum install -y mongodb-org
sudo cp /tmp/mongod.conf /etc/mongod.conf
sudo service mongod start
mongo admin /tmp/users_roles.js
sudo service mongod stop
sudo sed -i -e "s|disabled|enabled|g" /etc/mongod.conf
sudo service mongod start

