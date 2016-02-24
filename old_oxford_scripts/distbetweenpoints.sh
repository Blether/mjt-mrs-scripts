#!/usr/local/bin/bash
# this calculates the distance between two points in 3D space
# takes x y z x2 y2 z2 as arguments

xdif=$(echo $1 - $4| bc -l)
ydif=$(echo $2 - $5| bc -l)
zdif=$(echo $3 - $6| bc -l)
echo "sqrt((${xdif}^2) + (${ydif}^2) + (${zdif}^2))" |bc -l
