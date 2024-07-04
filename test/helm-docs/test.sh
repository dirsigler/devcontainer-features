#!/bin/bash

set -e

source dev-container-features-test-lib

check "helm-docs version on bash" helm-docs --version

reportResults
