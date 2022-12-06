#!/bin/bash

USER=harini44
NUMHOSTS=2
EXPERIMENTNAME=quant-dg-exp
PROJECTNAME=CloudMigration
# LOCATION=utah
LOCATION=emulab
# LOCATION=clemson
SITE=net

pids=()

# setup controller
NODE_SYSTEM="${USER}@nfs.${EXPERIMENTNAME}.${PROJECTNAME}.${LOCATION}.${SITE}"
# NODE_SYSTEM="${USER}@nfs.${EXPERIMENTNAME}.cloudmigration.emulab.net"
echo $NODE_SYSTEM
ssh -i ~/.ssh/netshare-package -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $NODE_SYSTEM "sudo -n env RESIZEROOT=192 bash -s" < grow-rootfs.sh
ssh -i ~/.ssh/netshare-package -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $NODE_SYSTEM "bash -s" < setup-cpu.sh "dg-torch" & 
scp -i ~/.ssh/netshare-package -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ~/.ssh/netshare-package $NODE_SYSTEM:~/.ssh/id_rsa &
pids+=($!)

# setup workers
COUNTER=1
while [  $COUNTER -lt $NUMHOSTS ]; do
    NODE="node${COUNTER}" 
    NODE_SYSTEM="${USER}@${NODE}.${EXPERIMENTNAME}.${PROJECTNAME}.${LOCATION}.${SITE}"
    # NODE_SYSTEM="${USER}@${NODE}.${EXPERIMENTNAME}.cloudmigration.emulab.net"
    echo $NODE_SYSTEM

    ssh -i ~/.ssh/netshare-package -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $NODE_SYSTEM "sudo -n env RESIZEROOT=192 bash -s" < grow-rootfs.sh
    ssh -i ~/.ssh/netshare-package -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $NODE_SYSTEM "bash -s" < setup-cpu.sh "dg-torch" & 
    scp -i ~/.ssh/netshare-package -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ~/.ssh/netshare-package $NODE_SYSTEM:~/.ssh/id_rsa &

    pids+=($!)
    let COUNTER=COUNTER+1
done

for pid in "${pids[@]}"; do
    wait "$pid"
done

echo "script done"