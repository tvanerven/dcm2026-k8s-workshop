#!/bin/sh
cd /data
echo "ok - created index file" | tee index.html
df -Th . | tee -a index.html