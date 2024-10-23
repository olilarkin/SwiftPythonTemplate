#!/bin/sh

pyenv install 3.11
pyenv shell 3.11
python3.11 -m pip install --target=./Template/app_packages -r requirements.txt
