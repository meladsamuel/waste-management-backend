#!/bin/bash
# Select the Default python to work with
export PYTHON_VERSION=3.7.2
export PYTHON_SHORT_VERSION=3.7
export PYTHON_MAJOR=3


# Install required dependencies for python
sudo apt-get build-dep python -y
sudo apt-get install libffi-dev libgdbm-dev libsqlite3-dev libssl-dev zlib1g-dev -y


# Download and extract Python 
curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar -xvzf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}


# Build and install Python
./configure --enable-optimizations
make -j 8
sudo make altinstall


# Install pip and virtualenv
curl -O https://bootstrap.pypa.io/get-pip.py
sudo /usr/local/bin/python${PYTHON_SHORT_PYTHON_DIR} get-pip.py
sudo /usr/local/bin/pip${PYTHON_SHORT_VERSION} install virtualenv



# Verify Python installation for python
/usr/local/bin/python${PYTHON_SHORT_VERSION} --version
