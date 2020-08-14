#!/bin/bash

if [ $(uname) == 'Darwin' ]; then
  sed -i '' 's/declare enum/enum/g' lib/typescript/src/index.d.ts
  else
  sed -i 's/declare enum/enum/g' lib/typescript/src/index.d.ts
fi
