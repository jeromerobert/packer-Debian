#!/bin/sh -ex
apt-get clean
rm -rf /var/lib/apt/lists/* /var/log/*
# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync