#!/usr/bin/env bash
#
ANSIBLE_PLAYBOOK=$(which ansible-playbook)
VAULT_FILE=vault-file
CISPRJ=https://github.com/ansible-lockdown/RHEL8-CIS
CISCOMMIT=3f25e1c4ceb729cefb5530d4eca15ae2feeddd38

run_playbooks () {
    PLAYBOOKS=("$@")
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
}

run_cis () {
    git clone "${CISPRJ}" CISPRJ
    cp -f extra-vars-cis.yaml CISPRJ/
    cp -f ${VAULT_FILE} CISPRJ/
    cp -f hosts-templaterhv CISPRJ/
    cd CISPRJ
    git checkout ${CISCOMMIT}
    $ANSIBLE_PLAYBOOK --vault-password-file $VAULT_FILE -i hosts-templaterhv --extra-vars "@extra-vars-cis.yaml" site.yml | tee -a ../log-cis.log
    STATUS=$?
    if [ ${STATUS} -gt 0 ]; then
        echo "Error in CIS playbook ${CISPRJ}... Exit"
        exit ${STATUS}
    fi
    cd ..
    if [ -d CISPRJ ]; then
        rm -rf CISPRJ
    fi
}

PLAYBOOKS=(clean.yaml satellite-ovirt.yaml ovirt.yaml vm-customize.yaml vm-hardening.yaml )
run_playbooks "${PLAYBOOKS[@]}"

run_cis

PLAYBOOKS=(vm-cleanup.yml ovirt-make-template.yaml clean-ovirt.yaml)
run_playbooks "${PLAYBOOKS[@]}"
