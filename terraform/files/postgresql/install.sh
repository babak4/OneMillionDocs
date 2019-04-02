echo "Installing PostgreSQL 11"
sudo yum install -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-redhat11-11-2.noarch.rpm
sudo yum install -y postgresql11
sudo yum install -y postgresql11-server

echo "Starting PostgreSQL"
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /var/lib/pgsql/11/data/postgresql.conf
sudo sed -i -e "s/host    all             all             127.0.0.1\/32            ident/host    all             all             0.0.0.0\/0               trust/" /var/lib/pgsql/11/data/pg_hba.conf
sudo sed -i -e "s/local   all             all                                     peer/local   all             all                                     trust/" /var/lib/pgsql/11/data/pg_hba.conf
sudo systemctl enable postgresql-11
sudo systemctl start postgresql-11.service
sudo systemctl stop firewalld
# sudo setsebool -P httpd_can_network_connect_db 1
# sudo setenforce 0

sudo su - postgres -c "psql -d template1 -a -f /tmp/create_user_and_db.sql"
echo "json_docs" | sudo su - postgres -c "createdb -O json_docs oneMillionDocDB"
sudo systemctl restart postgresql-11
PGPASSWORD="json_docs" psql -U json_docs -d oneMillionDocDB -a -f /tmp/DDL.sql
# psql -U postgres -d postgres -a -f /tmp/DDL.sql