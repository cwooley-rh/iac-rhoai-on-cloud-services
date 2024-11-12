.PHONY: ansible.%
ansible.%:
	$(MAKE) -C ansible $*
