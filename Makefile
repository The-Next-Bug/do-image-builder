SUBDIRS := $(wildcard */.)

ci: $(SUBDIRS)

# see: https://stackoverflow.com/a/17845120/876884
$(SUBDIRS):
	@$(MAKE) -w -C $@ $(MAKECMDGOALS)
 
# Update all submodules
ci-update:
	git submodule update --remote --rebase
	git add .
	git commit -m "Updating submodules..."
	git push

.PHONY: $(SUBDIRS) ci update
