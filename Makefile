
# see: https://stackoverflow.com/a/6145814/876884
FILTER_OUT = $(foreach v,$(2),$(if $(findstring $(1),$(v)),,$(v)))

SUBDIRS := $(call FILTER_OUT, charts, $(wildcard images/*/.))

NOW := $(shell date -u '+%Y-%m-%dT%H-%M-%Sz')

ci: $(SUBDIRS)

# see: https://stackoverflow.com/a/17845120/876884
$(SUBDIRS):
	@$(MAKE) -w -C $@ NOW=$(NOW) $(MAKECMDGOALS)
 
# Update all submodules
ci-update:
	git submodule update --remote --rebase
	git add .
	git commit -m "Updating submodules..."
	git push

.PHONY: $(SUBDIRS) ci update
