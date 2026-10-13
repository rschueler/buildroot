################################################################################
#
# docker-cli
#
################################################################################

DOCKER_CLI_VERSION = 29.9.0
DOCKER_CLI_SITE = $(call github,docker,cli,v$(DOCKER_CLI_VERSION))

DOCKER_CLI_LICENSE = Apache-2.0
DOCKER_CLI_LICENSE_FILES = LICENSE

DOCKER_CLI_DEPENDENCIES = host-pkgconf

DOCKER_CLI_CPE_ID_VENDOR = docker
DOCKER_CLI_CPE_ID_PRODUCT = docker

DOCKER_CLI_TAGS = autogen
DOCKER_CLI_BUILD_TARGETS = cmd/docker
DOCKER_CLI_GOMOD = github.com/docker/cli

DOCKER_CLI_LDFLAGS = \
	-X $(DOCKER_CLI_GOMOD)/cli/version.GitCommit=$(DOCKER_CLI_VERSION) \
	-X $(DOCKER_CLI_GOMOD)/cli/version.Version=$(DOCKER_CLI_VERSION)

ifeq ($(BR2_PACKAGE_DOCKER_CLI_STATIC),y)
DOCKER_CLI_LDFLAGS += -extldflags '-static'
DOCKER_CLI_TAGS += osusergo netgo
DOCKER_CLI_GO_ENV = CGO_ENABLED=no
endif

# docker/cli ships vendor.mod/vendor.sum instead of go.mod/go.sum, because it
# is CalVer and cannot opt in to the module rules. Upstream builds by linking
# them into place; do the same. The old hook wrote a synthetic go.mod with
# "go 1.19" and deleted vendor/modules.txt, which stopped working once the
# sources used newer language features (range over int in 29.x, needs 1.22+):
# the go line must come from vendor.mod, and modules.txt stays because it was
# generated from that very file and is consistent with it.
define DOCKER_CLI_FIX_VENDORING
	cp $(@D)/vendor.mod $(@D)/go.mod
	if [ -f $(@D)/vendor.sum ]; then cp $(@D)/vendor.sum $(@D)/go.sum; fi
endef
DOCKER_CLI_POST_EXTRACT_HOOKS += DOCKER_CLI_FIX_VENDORING

$(eval $(golang-package))
