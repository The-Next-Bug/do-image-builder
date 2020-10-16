
CHARTS = $(CURDIR)/helm-charts

# see: https://stackoverflow.com/a/6145814/876884
FILTER_OUT = $(foreach v,$(2),$(if $(findstring $(1),$(v)),,$(v)))

SUBDIRS := $(call FILTER_OUT, charts, $(wildcard images/*/.))

NOW := $(shell date -u '+%Y-%m-%dT%H-%M-%Sz')

ci: $(SUBDIRS)

$(CHARTS): 
	git clone --depth 1 git@github.com:The-Next-Bug/helm-charts.git $(CHARTS)


# see: https://stackoverflow.com/a/17845120/876884
$(SUBDIRS): $(CHARTS)
	cd $(CHARTS) && git pull
	@$(MAKE) -w -C $@ NOW=$(NOW) TAG_PATH=$(CHARTS)/site-deploy $(MAKECMDGOALS)
 
# Update all submodules
ci-update:
	git submodule update --remote --rebase
	git add .
	git commit -m "Updating submodules..."
	git push

.PHONY: $(SUBDIRS) ci update
