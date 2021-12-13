#!/bin/bash
mosh --ssh="ssh -p 2222 -oStrictHostKeyChecking=no" user@10.6.0.2 -- sh -c "cat /data/file_10M.dat"
