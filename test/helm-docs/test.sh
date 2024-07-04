#!/bin/bash

set -e

source dev-container-features-test-lib

check "helm-docs on bash" helm-docs

reportResults
