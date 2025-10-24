#!/bin/sh
nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,nounits,noheader | awk '{printf "%d\n%d\n", $1, $2}'