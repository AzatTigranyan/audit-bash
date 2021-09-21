#!/bin/bash
set -e

HOME_PATH="/usr/share/auditbeat"
CONF_PATH="/etc/auditbeat"
LOG_PATH="/var/log/auditbeat"
DATA_PATH="/var/lib/auditbeat"
BIN_PATH="/usr/bin"
SYSTEMD_PATH="/etc/systemd/system"
SHASUM="d26d624bcf65aa9df9e4b90df261530862bcb25110a66461db1eda88ca0b0e94"
WGET_LINK=""

a=0
! which auditbeat &> /dev/null || a=$?
! ls /usr/share/auditbeat &> /dev/null || a=$(($a + $?))
! ls /etc/systemd/system/auditbeat.system &> /dev/null || a=$(($a + $?))
! ls /lib/systemd/system/auditbeat.system &> /dev/null || a=$(($a + $?))
! ls /var/log/auditbeat &> /dev/null || a=$(($a + $?))
if [ $a != 0 ]; then
        echo "Auditbeat already installed, removing!"
        rm -rf $HOME_PATH $CONF_PATH $LOG_PATH $DATA_PATH $BIN_PATH/auditbeat $SYSTEMD_PATH/auditbeat.service
        echo "Auditbeat removed!"
fi

echo "Downloading Auditbeat source!"
#wget $WGET_LINK &&
if [ $(sha256sum auditbeat-7.14.1.tar.gz | cut -d " " -f1) != "$SHASUM" ]; then
        echo "CORRUPTED SOURCE!" && exit
else
        echo "Source is ok, installing!"
        tar xf auditbeat-7.14.1.tar.gz && cd auditbeat-7.14.1 &&
        mkdir $CONF_PATH &&
        mkdir $DATA_PATH &&
        mkdir $LOG_PATH &&
        mkdir -p $HOME_PATH/bin &&
        cp auditbeat_usr $BIN_PATH/auditbeat &&
        cp -r auditbeat.yml auditbeat.reference.yml fields.yml audit.rules.d $CONF_PATH &&
        cp -r auditbeat.yml auditbeat.reference.yml fields.yml audit.rules.d kibana $HOME_PATH &&
        cp auditbeat $HOME_PATH/bin &&
        cp auditbeat.service $SYSTEMD_PATH &&
        systemctl enable auditbeat &&
        systemctl start auditbeat &&
        echo "Installation complete!"
fi
