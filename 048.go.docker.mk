# https://github.com/mikefarah/yq/blob/master/Makefile.variables
export PROJECT = yq
IMPORT_PATH := github.com/mikefarah/${PROJECT}

export GIT_COMMIT = $(shell git rev-parse --short HEAD)
export GIT_DIRTY = $(shell test -n "$$(git status --porcelain)" && echo "+CHANGES" || true)
export GIT_DESCRIBE = $(shell git describe --tags --always)
LDFLAGS :=
LDFLAGS += -X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}
LDFLAGS += -X main.GitDescribe=${GIT_DESCRIBE}

GITHUB_TOKEN ?=

# Windows environment?
CYG_CHECK := $(shell hash cygpath 2>/dev/null && echo 1)
ifeq ($(CYG_CHECK),1)
	VBOX_CHECK := $(shell hash VBoxManage 2>/dev/null && echo 1)

	# Docker Toolbox (pre-Windows 10)
	ifeq ($(VBOX_CHECK),1)
		ROOT := /${PROJECT}
	else
		# Docker Windows
		ROOT := $(shell cygpath -m -a "$(shell pwd)")
	endif
else
	# all non-windows environments
	ROOT := $(shell pwd)
endif

DEV_IMAGE := ${PROJECT}_dev

DOCKRUN := docker run --rm \
	-e LDFLAGS="${LDFLAGS}" \
	-e GITHUB_TOKEN="${GITHUB_TOKEN}" \
	-v ${ROOT}/vendor:/go/src \
	-v ${ROOT}:/${PROJECT}/src/${IMPORT_PATH} \
	-w /${PROJECT}/src/${IMPORT_PATH} \
	${DEV_IMAGE}
