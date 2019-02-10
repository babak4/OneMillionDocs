echo "Installing PostgreSQL 11"
yum install -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-redhat11-11-2.noarch.rpm
yum install -y postgresql11
yum install -y postgresql11-server

echo "Starting PostgreSQL"
/usr/pgsql-11/bin/postgresql-11-setup initdb
sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /var/lib/pgsql/11/data/postgresql.conf
sed -i -e "s/host    all             all             127.0.0.1\/32            ident/host    all             all             0.0.0.0\/0               md5/" /var/lib/pgsql/11/data/pg_hba.conf
systemctl enable postgresql-11
systemctl start postgresql-11.service
systemctl stop firewalld
