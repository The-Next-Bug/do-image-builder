# see: https://stackoverflow.com/a/17845120/876884
TOPTARGETS := ci 

SUBDIRS := $(wildcard */.)

$(TOPTARGETS): $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -w -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
