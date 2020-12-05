#!/bin/bash

cat $1 | head -n $2 | cut -d "," -f3 | xargs -L1 ./altsvc-header.sh

