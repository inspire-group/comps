#!/bin/bash

cat $1 | head -n 1001 | cut -d "," -f3 | xargs -L1 ./altsvc-header.sh

