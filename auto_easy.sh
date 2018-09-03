#!/bin/bash

install_home="/root/install"

node_exporter_files="/root/install/csk/csk_ansible/roles/node_exporter/files"

if [ -f "${node_exporter_files}/node_exporter.tar.xz" ]; then
    rm -rf "${node_exporter_files}/node_exporter.tar.xz"
fi

mv /home/fonsview/node_exporter.tar.xz "${node_exporter_files}"

fsv_agent_home="/root/install/fsv_agent"
pvc="$1"

"${fsv_agent_home}/fsv_agent" -i "${fsv_agent_home}/${pvc}/hosts.txt" -run 'rm /opt/fonsview/3RD/node_exporter/textfile_scripts/node_*'
"${fsv_agent_home}/fsv_agent" -i "${fsv_agent_home}/${pvc}/hosts.txt" -run 'rm /opt/fonsview/3RD/node_exporter/textfile_scripts/ENV'
"${fsv_agent_home}/fsv_agent" -i "${fsv_agent_home}/${pvc}/hosts.txt" -run 'rm /opt/fonsview/3RD/node_exporter/cron.d/cron_*'
"${fsv_agent_home}/fsv_agent" -i "${fsv_agent_home}/${pvc}/hosts.txt" -run 'rm -f /etc/cron.d/cron_node_exporter_textfile_*'
"${fsv_agent_home}/fsv_agent" -i "${fsv_agent_home}/${pvc}/hosts.txt" -run 'rm -f /opt/fonsview/3RD/node_exporter/textfile_collector/node_*.prom'
"${fsv_agent_home}/fsv_agent" -i "${fsv_agent_home}/${pvc}/hosts.txt" -run 'rm -f /dev/shm/node_*'

csk_ansible="/root/install/csk/csk_ansible"

lines=`cat "${csk_ansible}/hosts_${pvc}" | wc -l`

count=`ansible-playbook -i "${csk_ansible}/hosts_${pvc}" "${csk_ansible}/test_ssh_ping.yml" | grep -c ok=1`

if [ ${count} -eq ${lines} ]; then
    echo "host_${pvc} has ${lines} lines, is right, now do the next!"
    ansible-playbook -i "${csk_ansible}/hosts_${pvc}" "${csk_ansible}/node_exporter.yml"
fi
