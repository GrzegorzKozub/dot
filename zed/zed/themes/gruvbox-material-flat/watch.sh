#!/usr/bin/env bash
set -eo pipefail -ux

fswatch -o ./*.json* | while read -r; do ./build.sh; done
