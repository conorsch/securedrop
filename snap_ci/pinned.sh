#!/bin/bash
set -e
# Pin commands to install vagrant, ansible, serverspec
# Pinning commands will ensure that they are ran in each snap-ci stage. This is
# usefull when you only want to re-run one stage.

# Cache and install Vagrant
[[ -f ${SNAP_CACHE_DIR}/$vagrant_rpm ]] || wget https://dl.bintray.com/mitchellh/vagrant/$vagrant_rpm -O ${SNAP_CACHE_DIR}/$vagrant_rpm
[[ -x /usr/bin/vagrant ]] || sudo -E rpm -ivh ${SNAP_CACHE_DIR}/$vagrant_rpm
# TODO: Check for vagrant plugins before installing them.
# Not sure if caching the vagrant plugins is going to save much time,
# but this resource gives a good overview of the bundling procedure:
# http://3ofcoins.net/2013/06/10/installing-vagrant-plugins-from-local-file/
time vagrant plugin install vagrant-digitalocean --plugin-version '0.7.0'
time vagrant plugin install vagrant-hostmanager
[[ -f ${SNAP_CACHE_DIR}/digital_ocean.box ]] || wget https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box -O ${SNAP_CACHE_DIR}/digital_ocean.box
# TODO: Check to see if the box was already added before doing again.
time vagrant box add digital_ocean ${SNAP_CACHE_DIR}/digital_ocean.box --force

# Install Ansible dependencies
time sudo yum install ansible -y

# Install serverspec dependencies
time sudo yum install ruby rubygems -y
time gem install rspec serverspec bundler rake --no-ri --no-rdoc
