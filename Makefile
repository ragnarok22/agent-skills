.PHONY: import sync list

import:
	./tools/import-local-skills.sh

sync:
	./tools/sync-to-local.sh

list:
	find skills -mindepth 1 -maxdepth 1 -type d -print | sort
