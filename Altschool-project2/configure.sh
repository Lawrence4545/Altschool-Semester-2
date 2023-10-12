#!/bin/bash

username='altschool'
slaveip='192.168.56.8'

# Start and provision VMs
vagrant up

# create new user
vagrant ssh master -c "sudo useradd -s /bin/bash -m ${username}"

# add new user to sudo group
vagrant ssh master -c "sudo usermod -aG sudo ${username} && sudo passwd -d ${username}"

# generate sshkeys for new user
vagrant ssh master -c "sudo -u ${username} ssh-keygen -t rsa -P '' -f /home/${username}/.ssh/id_rsa"

# Modify the sshd_config file on slave node
vagrant ssh slave -c "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"

# restart ssh deamon on slave node
vagrant ssh slave -c "sudo systemctl reload sshd"

# Copy the public key to the Slave Node for passwordless SSH
vagrant ssh master -c "sudo -u ${username} ssh-copy-id vagrant@${slaveip}"

# create slave directory to copy to
vagrant ssh slave -c "sudo mkdir -p /mnt/altschool/slave"

# Copy data from Master node to Slave node
vagrant ssh master -c "sudo mkdir /mnt/altschool && sudo touch /mnt/altschool/test.txt /mnt/altschool/test0.txt"

vagrant ssh master -c "sudo -u ${username} rsync --rsync-path='sudo rsync' -r /mnt/altschool/* vagrant@${slaveip}:/mnt/altschool/slave/"

# Display process overview on the Master Node
vagrant ssh master -c "top"
