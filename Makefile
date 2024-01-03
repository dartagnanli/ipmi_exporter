# Copyright 2021 The Prometheus Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PKG_NAME = ezone.ksyun.com/ezone/luban/ipmi_exporter
COMMIT := $(shell git rev-parse --short HEAD)
VERSION := $(shell git describe --tags)
BuildTime := $(shell git show -s --format=%cd)
SERVER_DIR := "."
BRANCH := $(shell git branch)
user := $(shell whoami)
hostname := $(shell hostname)

# Override the default common all.
.PHONY: all
all: precheck style unused build test

.PHONY: build-image
build-image:
	docker buildx build \
	--platform linux/amd64,linux/arm64 \
	--build-arg COMMIT=$(COMMIT) \
	--build-arg VERSION=$(VERSION) \
	--build-arg BRANCH=$(BRANCH) \
	--build-arg SERVER_DIR="$(SERVER_DIR)" \
	--build-arg PKG_NAME="$(PKG_NAME)" \
	--build-arg user="$(user)" \
	--build-arg hostname="$(hostname)" \
	-f Dockerfile_multi \
	-t harbor.inner.galaxy.ksyun.com/luban/ipmi_exporter:$(VERSION) ./ --push
	echo -e "\n>>> '编译成功'"

.PHONY: build-single
build-single:
	docker build \
	--build-arg VERSION=$(VERSION) \
	--build-arg BRANCH="$(BRANCH)" \
	--build-arg user="$(user)" \
	--build-arg hostname="$(hostname)" \
	-f Dockerfile_multi \
	-t harbor.inner.galaxy.ksyun.com/luban/ipmi_exporter:$(VERSION) ./
	echo -e "\n>>> '编译成功'"

#DOCKER_ARCHS      ?= amd64 arm64
DOCKER_ARCHS      ?= amd64
DOCKER_IMAGE_NAME ?= ipmi-exporter
DOCKER_REPO       ?= prometheuscommunity

include Makefile.common
