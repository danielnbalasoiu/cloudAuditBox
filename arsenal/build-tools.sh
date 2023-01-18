#!/usr/bin/env bash

export USER=auditor

echo "Installing tools..."

# This function will install all Python packages defined in the python-tools.txt file
function pythonTools() {
	pip install awscli		# Install awscli system wide instead just inside pipenv
	pipenv install --ignore-pipfile --requirements /tmp/python-tools.txt
	echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
}

function prowlerV2(){
	git clone https://github.com/prowler-cloud/prowler
	cd ./prowler
	git checkout origin/prowler-2 2>/dev/null		# Ignoring 'detached HEAD' state error message
}

# Nothing here yet
function customTools() {
	mkdir -p ~/tools && cd ~/tools
	prowlerV2
}

#------#
# Main #
#------#
pythonTools
customTools

