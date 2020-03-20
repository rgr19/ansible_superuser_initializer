# special targets not associated with files, e.g.: 
# clean:
#  rm -rf *.o
.PHONY: setup cluster clusterv check all

check-env:
ifndef SUPERUSER
	$(error SUPERUSER is undefined)
endif
# ifndef SLAVES_MACS
# 	$(error SLAVES_MACS is undefined)
# endif

export PROJECT_NAME = $(shell basename $(PWD))
export ANSIBLE_VAULT_PASSWORD_FILE = ${HOME}/.ansible/vaults/${PROJECT_NAME}
setup: 
	echo ${PROJECT_NAME}
	bash scripts/install_ansible.sh 
	bash scripts/setup_vault.sh 
	bash scripts/encrypt_credentials.sh

CLUSTER=ANSIBLE_NOCOWS=1 ansible-playbook main.yml -i inventories -e superuser=${SUPERUSER}
cluster: check-env setup
	$(CLUSTER)
clusterv: check-env setup
	$(CLUSTER) -v
check: check-env setup
	$(CLUSTER) --syntax-check

all: check-env setup check cluster
