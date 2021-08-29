#!/bin/sh


git pull
git submodule sync
git submodule update --init --recursive
git submodule update --remote --merge
