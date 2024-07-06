#!/bin/bash

set -e

source dev-container-features-test-lib

check "helm-docs exists" which helm-docs
check "helm-docs version" helm-docs --version

reportResults
