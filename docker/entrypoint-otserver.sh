#!/bin/sh
set -eu
/usr/local/bin/render-config.sh
exec theforgottenserver "$@"
