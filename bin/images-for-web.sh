#!/usr/bin/env bash
for i in *.*; do
  printf "Resize $i\n"
  convert "$i" -resize "1024^>" "resize-$i"
done
