.PHONY: check tools non-tools data

check: tools data non-tools

tools:
	make -C stdin-is-backupname check

data:
	make -C common/data

non-tools:
	make -C cb check
