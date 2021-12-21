#!/usr/bin/env bash

if [ -d ../venv/tmp/python ]; then
  rm -rf ../venv/tmp/python
fi
mkdir -p ../venv/tmp/python/
cp -R ../venv/lib/python*/ ../venv/tmp/python/
cp ../main_function.py ../venv/tmp/python/site-packages/

terraform $1