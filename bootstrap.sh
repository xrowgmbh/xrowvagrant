#!/usr/bin/env bash

RPM_EPEL=http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RPM_XROW=http://packages.xrow.com/redhat/6/xrow-repo-2.1-24.noarch.rpm

yum -y groupinstall Base

yum -y install openssh-server grub yum-priorities

#Very important, else there is no communication
yum -y install dhclient

yum -y install ${RPM_EPEL}
yum -y install http://elrepo.org/linux/elrepo/el6/x86_64/RPMS/elrepo-release-6-4.el6.elrepo.noarch.rpm
yum -y install http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm
yum -y install ${RPM_XROW}

yum -y --disablerepo=* --enablerepo=xrow update xrow-repo

yum -y install python-devel gcc libyaml libyaml-devel

yum -y install redhat-lsb which

yum -y install cloud-init

# needed for ez cluster
yum -y install drbd83 kmod-drbd83
yum -y install gfs2-utils nfs-utils rpcbind cman rgmanager lvm2-cluster

yum -y install xrow-zend xrow-zend-packages
yum -y --enablerepo=xrow-opt install ezcluster
yum -y install ezpublish
yum -y install ezlupdate
yum -y install jmeter

yum -y install emacs

yum install newrelic-php5

# mlocate will crawl /mnt/nas
yum -y remove mlocate

yum -y install ruby ec2-ami-tools ec2-api-tools

curl https://github.com/timkay/aws/raw/master/aws -o /bin/aws
chmod +x /bin/aws

cat <<EOL > /etc/motd
##########################################################
# eZ XROW Cluster for Amazon                             #
##########################################################
EOL

cat <<EOL > /etc/sysconfig/network
NETWORKING=yes
EOL

cat <<EOL > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
NM_CONTROLLED="no"
ONBOOT=yes
TYPE=Ethernet
BOOTPROTO=dhcp
DEFROUTE=yes
PEERDNS=yes
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=yes
EOL

cat <<EOL > /etc/drbd.conf 
global {
  usage-count no; 
}
common {
  protocol C;
}
EOL

passwd -l root
passwd -l ec2-user
pwconv
################################################
#### turn on/off some required services     ####
################################################

chkconfig --level 2345 network on
chkconfig iptables off
chkconfig ip6tables off

################################################
#### turn off some other services if needed ####
################################################

chkconfig --level 2345 rpcbind on
chkconfig microcode_ctl off
chkconfig iptables off
chkconfig rpcgssd off
chkconfig rpcidmapd off
chkconfig haldaemon off
chkconfig sendmail off
chkconfig zend-server off
chkconfig ezfind-solr off
chkconfig mysqld off
chkconfig nfs off
chkconfig nfslock off
chkconfig drbd off
chkconfig varnish off
chkconfig httpd off
chkconfig varnishlog off

echo "Stoping services"

/etc/init.d/zend-server stop
/etc/init.d/ezfind-solr stop
/etc/init.d/mysqld stop
/etc/init.d/nfs stop
/etc/init.d/nfslock stop
/etc/init.d/drbd stop
/etc/init.d/varnish stop
/etc/init.d/varnishlog stop
/etc/init.d/xinetd stop

################################################
#### Cluster Setup                          ####
################################################

sed -i "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config



cat <<EOL > /etc/cloud/cloud.cfg.d/10_ezcluster.cfg
cloud_type: auto
user: ec2-user
disable_root: 0
mounts:
 - [ ephemeral0, /mnt/ephemeral, auto, "defaults,noexec,nobootwait" ]
 - [ ephemeral1, /mnt/ephemeral2, auto, "defaults,noexec,nobootwait" ]
 - [ swap, none, swap, sw, "0", "0" ]
preserve_hostname: True
EOL

################################################
#### Do some eZ stuff                       ####
################################################

mkdir ~/.subversion
cat <<EOL > ~/.subversion/config
[global]
store-passwords = no
store-auth-creds = no
EOL

mkdir -p ~/.ssh
cat <<EOL > ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAmKtOFjv/OLjzPP7VyjndOJJvxfzOIEfhJ+FXhiUVTOFFdTMXV2si0rqL3I8ot2mwM8bpeqvQr5zfng0CPOxl8ydkPsRY2qflyKWO19/nV3R/R5z29P+DgyQgfAiK5gbh2mMgdRkLn0MmE2GULKu7OGPUXIgRJpUTBVziySMAcSU= service@xrow.de
EOL

mkdir -p /home/ec2-user/.ssh
cat <<EOL > /home/ec2-user/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAmKtOFjv/OLjzPP7VyjndOJJvxfzOIEfhJ+FXhiUVTOFFdTMXV2si0rqL3I8ot2mwM8bpeqvQr5zfng0CPOxl8ydkPsRY2qflyKWO19/nV3R/R5z29P+DgyQgfAiK5gbh2mMgdRkLn0MmE2GULKu7OGPUXIgRJpUTBVziySMAcSU= service@xrow.de
EOL
cat <<EOL > /home/ec2-user/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=\$PATH:\$HOME/bin

export PATH

SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"
if [ -z "\$SSH_AUTH_SOCK" -a -x "\$SSHAGENT" ]; then
  eval `\$SSHAGENT \$SSHAGENTARGS > /dev/null 2>&1`
  trap "kill \$SSH_AGENT_PID" 0
fi
EOL
cat <<EOL > /home/ec2-user/.logout
if [ \${SSH_AGENT_PID+1} == 1 ]; then
   ssh-add -D
   ssh-agent -k > /dev/null 2>&1
   unset SSH_AGENT_PID
   unset SSH_AUTH_SOCK
fi
EOL
chown -R ec2-user:ec2-user /home/ec2-user
mv /etc/ssh/ssh_config /etc/ssh/ssh_config.default
cat <<EOL > /etc/ssh/ssh_config
Host *
    GSSAPIAuthentication yes
    HostbasedAuthentication yes
    ForwardAgent yes
    ForwardX11Trusted yes
    SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES 
    SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT 
    SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
    SendEnv XMODIFIERS
EOL

mv /etc/ssh/sshd_config /etc/ssh/sshd_config.default
cat <<EOL > /etc/ssh/sshd_config
Protocol 2

SyslogFacility AUTHPRIV
PermitRootLogin no

RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile	.ssh/authorized_keys

PasswordAuthentication no

ChallengeResponseAuthentication no


GSSAPIAuthentication yes
GSSAPICleanupCredentials yes
HostbasedAuthentication yes

UsePAM yes

# Accept locale-related environment variables
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS

X11Forwarding yes

Subsystem	sftp	/usr/libexec/openssh/sftp-server

EOL

cat <<EOL > ~/.bashrc
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions

EOL

yum -y clean all
