sudo yum -y update
sudo sudo yum -y install gcc openssl-devel bzip2-devel libffi-devel wget
cd /usr/src
sudo wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
sudo tar xzf Python-3.7.2.tgz
cd Python-3.7.2
sudo ./configure --enable-optimizations
sudo make altinstall
sudo rm /usr/src/Python-3.7.2.tgz
sudo /usr/local/bin/python3.7 --version
sudo /usr/local/bin/python3.7 -m pip install --upgrade pip
sudo /usr/local/bin/python3.7 -m pip install pymongo cx_Oracle psycopg2-binary pandas

