#!/usr/bin/env bash

if [ -d ../venv/tmp/python ]; then
  rm -rf ../venv/tmp/python
fi
mkdir -p ../venv/tmp/python/
cp -R ../venv/lib/python*/ ../venv/tmp/python/
cp ../fetch_news.py ../venv/tmp/python/site-packages/
cp ../send_news.py ../venv/tmp/python/site-packages/
cp ../news_api.py ../venv/tmp/python/site-packages/

terraform $@