#!/usr/bin/env sh

rm -rf public

hugo && rsync -avz --delete public/ root@cloudnative.mx:/www/cloudnative.mx/public/