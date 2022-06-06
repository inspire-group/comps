#!/bin/bash

time curl server/file?size=1 --output 1M.dat
time curl server/file?size=10 --output 10M.dat
time curl server/file?size=100 --output 100M.dat
time curl server/file?size=1000 --output 1000M.dat