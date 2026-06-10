# Copyright Layer5, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include .github/build/Makefile.core.mk
include .github/build/Makefile.show-help.mk

#----------------------------------------------------------------------------
# Academy
# ---------------------------------------------------------------------------
.PHONY: setup build site serve clean check-go check-deps theme-update

## ------------------------------------------------------------
----LOCAL_BUILDS: Show help for available targets
	
## Local: Install site dependencies
setup:
	npm install

## Validate npm and local Hugo binary before execution
check-deps:
	@echo "Checking dependencies..."
	@command -v npm > /dev/null || (echo "npm is not installed. Please install Node.js."; exit 1)
	@npm ls hugo-extended > /dev/null || (echo "hugo-extended is not installed. Run 'make setup' first."; exit 1)
	@echo "Dependencies are satisfied."

## Local: Build site for local consumption
build: check-deps
	npm run dev:build

## Local: Build and run site locally with draft and future content enabled.
site: check-go check-deps
	npm run dev:site

## Local: Build and run site locally
serve: check-go check-deps
	npm run dev:serve
	
## Empty build cache and run on your local machine.
clean: check-deps
	npm run dev:clean
	make site

## ------------------------------------------------------------
----MAINTENANCE: Show help for available targets

check-go:
	@echo "Checking if Go is installed..."
	@command -v go > /dev/null || (echo "Go is not installed. Please install it before proceeding."; exit 1)
	@echo "Go is installed."

## Update the academy-theme package to latest version
theme-update: check-deps
	echo "Updating to latest academy-theme..." && \
	npm run dev:theme-update
