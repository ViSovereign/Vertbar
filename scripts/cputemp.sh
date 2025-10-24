#!/bin/sh
sensors | awk -F'[:+°]' '/Tdie|Tctl/ {printf "%s\n", $3}'