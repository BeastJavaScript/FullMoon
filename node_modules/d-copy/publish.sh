#!/usr/bin/env sh
cd $(dirname $0)
zbuild
git add --all
git commit -am"automatic publish"
git push origin
npm init