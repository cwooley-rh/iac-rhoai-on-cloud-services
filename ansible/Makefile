.PHONY: help virtualenv kind image deploy

CLUSTER_NAME ?= $(shell whoami)-test

VIRTUALENV ?= ./virtualenv
ANSIBLE = $(VIRTUALENV)/bin/ansible-playbook $(VERBOSITY) $(EXTRA_VARS)
COLLECTIONS_PATH=$(VIRTUALENV)/lib/python3.12/site-packages/ansible_collections

IGNORE_CERTS ?= false
IGNORE_CERTS_OPTION=
ifeq ($(IGNORE_CERTS), true)
IGNORE_CERTS_OPTION = --ignore-certs
endif

.PHONY: venv
venv:
	LC_ALL=en_US.UTF-8 python3 -m venv $(VIRTUALENV)
	$(VIRTUALENV)/bin/pip install --upgrade pip setuptools wheel
	$(VIRTUALENV)/bin/pip install --only-binary=:all: -r requirements.txt || $(VIRTUALENV)/bin/pip install -r requirements.txt
	$(VIRTUALENV)/bin/pip install --only-binary=:all: -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt || $(VIRTUALENV)/bin/pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt
	ANSIBLE_COLLECTIONS_PATH=$(COLLECTIONS_PATH) \
	ANSIBLE_ROLES_PATH="$(COLLECTIONS_PATH)/ansible_collections/bootstrap/workshop/roles" \
	$(VIRTUALENV)/bin/ansible-galaxy install -r requirements.yaml $(IGNORE_CERTS_OPTION) --force

.PHONY: create.%
create.%:
	ANSIBLE_COLLECTIONS_PATH=$(COLLECTIONS_PATH) \
	ANSIBLE_ROLES_PATH="$(COLLECTIONS_PATH)/bootstrap/workshop/roles:$(ANSIBLE_ROLES_PATH)" \
	$(VIRTUALENV)/bin/ansible-playbook -vv -i ./environment/$*/hosts create_cluster.yaml

.PHONY: delete.%
delete.%: destroy.$*

.PHONY: destroy.%
destroy.%:
	$(VIRTUALENV)/bin/ansible-playbook -vv -i ./environment/$*/hosts destroy_cluster.yaml

.PHONY: rhoai
rhoai:
	$(VIRTUALENV)/bin/ansible-playbook -vv install_rhoai.yaml

.PHONY: bastion.rhoai
bastion.rhoai:
	$(VIRTUALENV)/bin/ansible-playbook --ask-pass -vv bastion_install_rhoai.yaml
