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
* start.bat

Now you can ssh in on ssh://localhost:2222/ and browse to http://localhost/
