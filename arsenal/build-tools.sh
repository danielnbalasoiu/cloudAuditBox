#!/usr/bin/env bash

export USER=auditor

echo "Installing tools..."

# This function will install all Python packages defined in the python-tools.txt file
function pythonTools() {
	pipenv install --ignore-pipfile --requirements /tmp/python-tools.txt
}

# Nothing here yet
function customTools() {
mkdir -p ~/tools && cd ~/tools
}

#------#
# Main #
#------#
pythonTools
customTools

