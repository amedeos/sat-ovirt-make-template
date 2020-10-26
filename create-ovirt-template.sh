#!/usr/bin/env bash
#
ANSIBLE_PLAYBOOK=$(which ansible-playbook)
VAULT_FILE=vault-file
PLAYBOOKS=(clean.yaml satellite.yaml ovirt.yaml vm-customize.yaml vm-hardening.yaml vm-cleanup.yml ovirt-make-template.yaml clean.yaml)

for playbook in "${PLAYBOOKS[@]}"; do
    echo "Run playbook: ${playbook}"
    if [ "${playbook}" == "vm-hardening.yaml" ]; then
        echo "run with hosts file"
        $ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE -i hosts-templaterhv ${playbook}
    else
        $ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE ${playbook}
    fi
    STATUS=$?
    if [ ${STATUS} -gt 0 ]; then
        echo "Error in playbook ${playbook}... Exit"
        exit ${STATUS}
    fi
done
