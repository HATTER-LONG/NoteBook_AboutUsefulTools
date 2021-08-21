#!/bin/sh

git submodule update --init --recursive
git submodule update --remote --merge
git pull
