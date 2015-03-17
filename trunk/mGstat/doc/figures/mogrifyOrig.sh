#!/bin/sh

cp orig/*.png .
cp orig/*.eps .
mogrify -trim *.png
mogrify -geometry 600x300 *.png
 
