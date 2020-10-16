
CHARTS = helm-charts

# see: https://stackoverflow.com/a/6145814/876884
FILTER_OUT = $(foreach v,$(2),$(if $(findstring $(1),$(v)),,$(v)))

SUBDIRS := $(call FILTER_OUT, charts, $(wildcard images/*/.))

NOW := $(shell date -u '+%Y-%m-%dT%H-%M-%Sz')

ci: $(SUBDIRS) helm-commit

$(CHARTS):
	git clone --depth 1 https://$(GITHUB_ACTOR):$(GITHUB_TOKEN)@github.com/The-Next-Bug/helm-charts.git $(CHARTS)

helm-commit: $(SUBDIRS)
	cd $(CHARTS) \
		&& git add . \
		&& git commit -a -m 'CI: Updating site-deploy image tags' \
		&& git push

# see: https://stackoverflow.com/a/17845120/876884
$(SUBDIRS): $(CHARTS)
	cd $(CHARTS) && git pull --ff-only
	@$(MAKE) -w -C $@ NOW=$(NOW) TAG_PATH=$(CURDIR)/$(CHARTS)/site-deploy $(MAKECMDGOALS)
 
# Update all submodules
ci-update:
	git submodule update --remote --rebase
	git add .
	git commit -m "Updating submodules..."
	git push

.PHONY: $(SUBDIRS) ci update helm-commit
