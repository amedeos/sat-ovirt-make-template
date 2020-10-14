#!/usr/bin/env bash
#
ANSIBLE_PLAYBOOK=$(which ansible-playbook)
VAULT_FILE=vault-file
PLAYBOOKS=(clean.yaml satellite.yaml ovirt.yaml vm-customize.yaml vm-cleanup.yml ovirt-make-template.yaml clean.yaml)

for playbook in "${PLAYBOOKS[@]}"; do
    echo "Run playbook: ${playbook}"
    $ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE ${playbook}
    STATUS=$?
    if [ ${STATUS} -gt 0 ]; then
        echo "Error in playbook ${playbook}... Exit"
        exit ${STATUS}
    fi
done
