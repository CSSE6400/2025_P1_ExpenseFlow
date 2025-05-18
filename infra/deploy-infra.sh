#!/bin/bash

set -e

# usage
usage() {
  echo "Usage: $0 [--auto]"
  echo "  --auto Run terraform apply with -auto-approve"
  exit 1
}
# script args: either none or --auto
if [[ $# -gt 1 ]]; then
  usage
fi

AUTO_APPROVE=0
if [[ $# -eq 1 ]]; then
  if [[ "$1" == "--auto" ]]; then
    AUTO_APPROVE=1
  else
    usage
  fi
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRED_FILE="$SCRIPT_DIR/credentials"

if ! test -f "$SCRIPT_DIR/../credentials"; then
    echo "credentials file does not exist..."
    exit 1
fi

# run terraform apply
if [[ $AUTO_APPROVE -eq 1 ]]; then
  terraform -chdir="$SCRIPT_DIR" apply -auto-approve
else
  terraform -chdir="$SCRIPT_DIR" apply
fi