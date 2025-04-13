#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "php -v" php -v
check "php-fpm -v" php-fpm8.2 -v

check "php-xdebug-extension" php -m | grep "xdebug"
check "php-xdebug-config" php -i | grep "xdebug.mode" | grep " => debug"
check "php-redis-extension" php -m | grep "redis"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
