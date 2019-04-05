#!/bin/bash
#
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
# 
# Since: July, 2018
# Author: gerald.venzl@oracle.com
# Description: Installs Oracle database software
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

SSH_USER=`whoami`

echo 'INSTALLER: Started up'
export ORACLE_BASE="/opt/oracle"
export ORACLE_HOME="/opt/oracle/product/18c/dbhome_1"
export ORACLE_SID="ORCLCDB"
export ORACLE_PDB="ORCLPDB1"
export ORACLE_CHARACTERSET="AL32UTF8"
export ORACLE_EDITION="EE"
export ORACLE_PASSWORD="fr55fall"

# export SYSTEM_TIMEZONE = SYSTEM_TIMEZONE
# get up to date
# sudo yum upgrade -y

echo 'INSTALLER: System updated'

# fix locale warning
# sudo yum reinstall -y glibc-common
echo LANG=en_US.utf-8 | sudo tee --append /etc/environment
echo LC_ALL=en_US.utf-8 | sudo tee --append /etc/environment

# echo 'INSTALLER: Locale set'

# set system time zone
# sudo timedatectl set-timezone $SYSTEM_TIMEZONE
# echo "INSTALLER: System time zone set to $SYSTEM_TIMEZONE"

# Install Oracle Database prereq and openssl packages
cd /tmp
sudo yum localinstall -y oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm

sudo passwd oracle <<EOF
$ORACLE_PASSWORD
$ORACLE_PASSWORD
EOF

echo 'INSTALLER: Oracle preinstall and openssl complete'

# create directories
sudo mkdir -p $ORACLE_HOME && \
sudo mkdir -p /u01/app && \
sudo ln -s $ORACLE_BASE /u01/app/oracle

echo 'INSTALLER: Oracle directories created'

# set environment variables
echo "export ORACLE_BASE=$ORACLE_BASE" | sudo tee --append /home/oracle/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" | sudo tee --append /home/oracle/.bashrc && \
echo "export ORACLE_SID=$ORACLE_SID" | sudo tee --append /home/oracle/.bashrc   && \
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib" | sudo tee --append /home/oracle/.bashrc && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin" | sudo tee --append /home/oracle/.bashrc

echo "export ORACLE_BASE=$ORACLE_BASE" | tee --append /home/$SSH_USER/.bashrc && \
echo "export ORACLE_HOME=$ORACLE_HOME" | tee --append /home/$SSH_USER/.bashrc && \
echo "export ORACLE_SID=$ORACLE_SID" | tee --append /home/$SSH_USER/.bashrc   && \
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib" | tee --append /home/$SSH_USER/.bashrc && \
echo "export PATH=\$PATH:\$ORACLE_HOME/bin" | tee --append /home/$SSH_USER/.bashrc

echo 'INSTALLER: Environment variables set'

# Install Oracle

sudo unzip LINUX.X64_180000_db_home.zip -d $ORACLE_HOME/
sudo rm LINUX.X64_180000_db_home.zip
sudo sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" db_install.rsp && \
sudo sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" db_install.rsp && \
sudo sed -i -e "s|###ORACLE_EDITION###|$ORACLE_EDITION|g" db_install.rsp && \
sudo chown oracle:oinstall -R $ORACLE_BASE

echo "$ORACLE_PASSWORD" | su - oracle -c "echo yes | $ORACLE_HOME/runInstaller -silent -ignorePrereqFailure -waitforcompletion -responseFile /tmp/db_install.rsp"
sudo $ORACLE_BASE/oraInventory/orainstRoot.sh
sudo $ORACLE_HOME/root.sh
sudo rm /tmp/db_install.rsp

echo 'INSTALLER: Oracle software installed'

# create sqlnet.ora, listener.ora and tnsnames.ora
echo "$ORACLE_PASSWORD" | su - oracle -c "mkdir -p $ORACLE_HOME/network/admin"
echo "$ORACLE_PASSWORD" | su - oracle -c "echo 'NAME.DIRECTORY_PATH= (TNSNAMES, EZCONNECT, HOSTNAME)' > $ORACLE_HOME/network/admin/sqlnet.ora"

# Listener.ora
echo "$ORACLE_PASSWORD" | su - oracle -c "echo 'LISTENER = 
(DESCRIPTION_LIST = 
  (DESCRIPTION = 
    (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1)) 
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) 
  ) 
) 

DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
' > $ORACLE_HOME/network/admin/listener.ora"

echo "$ORACLE_PASSWORD" | su - oracle -c "echo '$ORACLE_SID=localhost:1521/$ORACLE_SID' > $ORACLE_HOME/network/admin/tnsnames.ora"
echo "$ORACLE_PASSWORD" | su - oracle -c "echo '$ORACLE_PDB= 
(DESCRIPTION = 
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $ORACLE_PDB)
  )
)' >> $ORACLE_HOME/network/admin/tnsnames.ora"

# Start LISTENER
echo "$ORACLE_PASSWORD" | su - oracle -c "lsnrctl start"

echo 'INSTALLER: Listener created'

# Create database

# Auto generate ORACLE PWD if not passed on

sudo sed -i -e "s|###ORACLE_SID###|$ORACLE_SID|g" /tmp/dbca.rsp && \
sudo sed -i -e "s|###ORACLE_PDB###|$ORACLE_PDB|g" /tmp/dbca.rsp && \
sudo sed -i -e "s|###ORACLE_CHARACTERSET###|$ORACLE_CHARACTERSET|g" /tmp/dbca.rsp && \
sudo sed -i -e "s|###ORACLE_PWD###|$ORACLE_PASSWORD|g" /tmp/dbca.rsp
echo "$ORACLE_PASSWORD" | su - oracle -c "dbca -silent -createDatabase -responseFile /tmp/dbca.rsp"
echo "$ORACLE_PASSWORD" | su - oracle -c "sqlplus / as sysdba <<EOF
   ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;
   exit;
EOF"
sudo rm /tmp/dbca.rsp

echo 'INSTALLER: Database created'

sudo sed '$s/N/Y/' /etc/oratab | sudo tee /etc/oratab > /dev/null
echo 'INSTALLER: Oratab configured'

# configure systemd to start oracle instance on startup
sudo cp /tmp/oracle-rdbms.service /etc/systemd/system/
sudo sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" /etc/systemd/system/oracle-rdbms.service
sudo systemctl daemon-reload
sudo systemctl enable oracle-rdbms
sudo systemctl start oracle-rdbms
echo "INSTALLER: Created and enabled oracle-rdbms systemd's service"

# sudo cp /tmp/setPassword.sh /home/oracle/ && \
# sudo chmod a+rx /home/oracle/setPassword.sh

# echo "INSTALLER: setPassword.sh file setup";

echo "ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: $ORACLE_PASSWORD";

source /home/$SSH_USER/.bashrc

sqlplus sys/$ORACLE_PASSWORD@localhost:1521/$ORACLE_PDB as sysdba @/tmp/DDL.sql

echo "INSTALLER: Installation complete, database ready to use!";