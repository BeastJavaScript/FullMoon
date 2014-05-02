#!/bin/env sh
cd $(dirname $0)
coffee -c  -o lib -j application.js src/*
coffee -c test/DCTest.coffee
node test/DCTest.js
