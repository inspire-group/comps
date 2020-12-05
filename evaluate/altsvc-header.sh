#!/bin/bash

curl https://$1 -v -L -s 2>&1 | grep Alt-Svc
