#!/usr/bin/env bash

#set -eu
set -x

export USER=auditor

echo "Installing tools..."

# This function will install all Python packages defined in the python-tools.txt file
function pythonTools() {
	pipenv install --ignore-pipfile --requirements /tmp/python-tools.txt
}

function customTools() {
mkdir -p ~/tools && cd ~/tools
# TODO: check if directories are already there. Just pull latest code
}

#------#
# Main #
#------#
pythonTools
#customTools
