Set your keyboard layout
localectl set-keymap de

Set your locale

vi /etc/locale.conf 
LANG="en_US.UTF-8"



Jenkins

sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

yum install java jenkins rpm-sign
sudo chkconfig jenkins on
sudo service jenkins restart
systemctl disable firewalld && systemctl stop firewalld

wget http://localhost:8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://localhost:8080 install-plugin checkstyle cloverphp crap4j dry htmlpublisher jdepend plot pmd violations xunit
java -jar jenkins-cli.jar -s http://localhost:8080 safe-restart

java -jar jenkins-cli.jar -s http://localhost:8080 help