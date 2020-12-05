#!/bin/bash

echo "$1:$(curl https://$1 -v -L -s 2>&1 | grep -i Alt-Svc)"
