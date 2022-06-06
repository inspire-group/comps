#!/bin/bash

for size in 1M 10M 100M 1000M
do
  head -c $size </dev/urandom > file_$size.dat
done