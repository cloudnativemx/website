#!/usr/bin/env bash

VER=$(grep "version" website.properties|cut -d'=' -f2)  && docker build -t cloudnativemx/website:$VER . #&& docker push cloudnativemx/website:$VER #&& kubectl set image deployment/website website=cloudnativemx/website:$VER'
