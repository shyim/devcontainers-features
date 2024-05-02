#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "php-version-8-is-installed" bash -c "php --version | grep '8.0'"
check "php-fpm-version-8-is-installed" bash -c "php-fpm8.0 --version | grep '8.0'"
check "composer-version" composer --version

# Report result
reportResults
