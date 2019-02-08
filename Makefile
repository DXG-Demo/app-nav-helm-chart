###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2017. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
SHELL = /bin/bash
STABLE_BUILD_DIR = repo/stable
STABLE_REPO_URL ?= https://raw.githubusercontent.com/IBM/charts/master/repo/stable/
STABLE_CHARTS := $(wildcard stable/*)

.DEFAULT_GOAL=all

$(STABLE_BUILD_DIR):
	@mkdir -p $@

.PHONY: charts charts-stable $(STABLE_CHARTS) 

# Default aliases: charts, repo

charts: charts-stable

repo: repo-stable

charts-stable: $(STABLE_CHARTS)
$(STABLE_CHARTS): $(STABLE_BUILD_DIR) 
	cv lint $@
	helm package $@ -d $(STABLE_BUILD_DIR)

.PHONY: repo repo-stable repo-incubating 

repo-stable: $(STABLE_CHARTS) $(STABLE_BUILD_DIR)
	helm repo index $(STABLE_BUILD_DIR) --url $(STABLE_REPO_URL)

.PHONY: all
all: repo-stable 