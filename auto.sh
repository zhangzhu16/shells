#!/bin/bash

install_home="/root/install"

if [ -d "${install_home}/ansible-2.4.1_el7" ]; then
    rm -rf "${install_home}/ansible-2.4.1_el7"
fi

if [ -d "${install_home}/csk" ]; then
    rm -rf "${install_home}/csk"
fi

if [ -f "${install_home}/csk.tar.xz" ]; then
    rm -rf "${install_home}/csk.tar.xz"
fi

cp /home/fonsview/csk.tar.xz "${install_home}"

tar -xvf "${install_home}/csk.tar.xz" -C "${install_home}"

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
