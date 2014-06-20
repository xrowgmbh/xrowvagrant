xrowvagrant
===========

Vagrant config for a eZ Publish Environment


Setup
===========

Prerequisites: 

Install and VirtualBox (http://www.virtualbox.org/) and Vagrant (http://www.vagrantup.com/) 

After that lets boot the development maschine

* git clone https://github.com/xrowgmbh/xrowvagrant xrowvagrant
* cp xrowvagrant/ezcluster/ezcluster.xml.dist xrowvagrant/ezcluster/ezcluster.xml
* cd xrowvagrant
* Opionally add your eZ Publish licence keys to ezcluster.xml.
* Run start.bat or start.sh

Now you can ssh in on ssh://localhost:2222/ and browse to http://localhost/
