#!/usr/bin/env bash

RPM_EPEL=http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RPM_XROW=http://packages.xrow.com/redhat/6/xrow-repo-2.2-47.noarch.rpm

yum -y update
yum -y groupinstall Base

yum -y install openssh-server grub yum-priorities

#Very important, else there is no communication
yum -y install dhclient

yum -y install ${RPM_EPEL}
yum -y install ${RPM_XROW}
yum -y --disablerepo=* --enablerepo=xrow update xrow-repo
yum -y install yum-cron

yum -y install python-devel gcc libyaml libyaml-devel

yum -y install redhat-lsb which

#Just for AWS
#yum -y install cloud-init

# needed for ez cluster
#yum -y install gfs2-utils nfs-utils rpcbind lvm2-cluster

yum -y remove mlocate
yum -y --enablerepo=xrow-opt install ezcluster
yum -y install ezpublish
yum -y install ezlupdate

# Plattform UI requirements
yum -y install nodejs npm nodejs-grunt freetype fontconfig
npm install -g grunt-cli yuidocjs grover
npm install -g bower
brew update && brew install phantomjs

/etc/init.d/vboxadd setup

#Git speed
#http://interrobeng.com/2013/08/25/speed-up-git-5x-to-50x/
cat <<EOL > /root/.ssh/config
ControlMaster auto
ControlPath /tmp/%r@%h:%p
ControlPersist yes
EOL
cat <<EOL > /home/ec2-user/.ssh/config
ControlMaster auto
ControlPath /tmp/%r@%h:%p
ControlPersist yes
EOL
chown ec2-user:ec2-user /home/ec2-user/.ssh/config

cd /etc/yum.repos.d
sudo wget http://www.hop5.in/yum/el6/hop5.repo
yum -y install hhvm
cd /
cat <<EOL > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-1.0]
name=Elasticsearch repository for 1.0.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.0/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOL
cat <<EOL > /etc/yum.repos.d/logstash.repo
[logstash-1.3]
name=logstash repository for 1.3.x packages
baseurl=http://packages.elasticsearch.org/logstash/1.3/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOL
yum -y clean all
yum install https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.2_x86_64.rpm
yum -y install elasticsearch logstash
sed -i "s/START=false/START=true/g" /etc/sysconfig/logstash

cat <<EOL > /etc/logstash/conf.d/ezcluster.conf
input {
  file {
    type => "syslog"
    path => [ "/var/log/*.log", "/var/log/messages", "/var/log/syslog" ]
  }
  file {
    type => "ezpublish"
    codec => "json"
    path => [ "/var/www/sites/*/ezpublish/logs/logstash.log" ]
  }
  file {
    type => "apache"
    path => [ "/var/log/httpd/access_log" ]
  }
  file {
    type => "php-error"
    path => [ "/usr/local/zend/var/log/php.log" ]
  }
}
output {
  elasticsearch_http {
     host => "localhost"
  }
}
EOL

wget http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip
unzip -d /var/www/ kibana-latest.zip
mv /var/www/kibana-latest /var/www/kibana
rm kibana-latest.zip
openssl genrsa -out ca.key 1024 
openssl req -batch -new -key ca.key -out ca.csr
openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt
mv ca.crt /etc/pki/tls/certs/ezcluster.crt
mv ca.key /etc/pki/tls/private/ezcluster.key
mv ca.csr /etc/pki/tls/private/ezcluster.csr

yum -y install redis
chkconfig redis on
/usr/local/zend/bin/pecl install redis
cat <<EOL > /usr/local/zend/etc/conf.d/redis.ini
extension=redis.so
EOL

/usr/local/zend/bin/pear channel-discover pear.twig-project.org
/usr/local/zend/bin/pear install twig/CTwig
cat <<EOL > /usr/local/zend/etc/conf.d/twig.ini
extension=twig.so
EOL

/usr/local/zend/bin/pecl install xhprof-beta
cat <<EOL > /usr/local/zend/etc/conf.d/xhprof.ini
extension=xhprof.so
EOL
mv /usr/local/zend/etc/conf.d/debugger.ini /usr/local/zend/etc/conf.d/debugger.ini.disabled

cat <<EOL > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-1.0]
name=Elasticsearch repository for 1.0.x packages
baseurl=http://packages.elasticsearch.org/elasticsearch/1.0/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOL
yum install elasticsearch
/sbin/chkconfig --add elasticsearch

yum -y install ruby ec2-ami-tools ec2-api-tools
curl https://github.com/timkay/aws/raw/master/aws -o /bin/aws

chmod +x /bin/aws

mv /etc/security/limits.conf /etc/security/limits.conf.dist
cat <<EOL > /etc/security/limits.conf
*          soft     nproc          65535
*          hard     nproc          65535
*          soft     nofile         65535
*          hard     nofile         65535
EOL

cat <<EOL > /etc/motd
##########################################################
# eZ XROW Cluster                                        #
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

chkconfig network on
chkconfig rpcbind on
chkconfig ntpd on
chkconfig iptables off
chkconfig ip6tables off

################################################
#### turn off some other services if needed ####
################################################


chkconfig microcode_ctl off
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

cat <<EOL > /home/ec2-user/.ssh/config
Host *
  ForwardAgent yes
EOL
chmod 600 /home/ec2-user/.ssh/config
chown ec2-user:ec2-user /home/ec2-user/.ssh/config

cat <<EOL > /home/ec2-user/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=\$PATH:\$HOME/bin

export PATH

SSH_ENV="\$HOME/.ssh/environment"

function start_agent {
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "\${SSH_ENV}"
    chmod 600 "\${SSH_ENV}"
    . "\${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
    if [ -f /vagrant/id_rsa ]; then
        ssh-add /vagrant/id_rsa
    elif [ -d /vagrant ]; then
        echo "No key imported in ssh agent. You migh want to place a key in /vagrant/id_rsa"
    fi
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "\${SSH_ENV}" > /dev/null
    ps -ef | grep \${SSH_AGENT_PID} | grep ssh-agent\$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
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

yum clean all

usermod -a -G apache ec2-user
usermod -a -G apache vagrant
usermod -a -G ec2-user vagrant