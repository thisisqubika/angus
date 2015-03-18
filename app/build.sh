#!/bin/bash

# tarFileName='ruy-page.tar'

rm -rf build
# rm $tarFileName


mkdir build

grunt precompile
jade views/home/index.jade --out ./build/ --pretty

cp -r public/* build/


rm -rf ../data ../dist ../fonts ../images ../index.html

cp -r build/* ../

# tar czf $tarFileName ./build