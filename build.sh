#!/usr/bin/env bash

VER=$(grep "version" website.properties|cut -d'=' -f2)  && \
  docker build -t cloudnativemx/website:latest -t cloudnativemx/website:$VER -t registry.circulosiete.com/library/cloudnativemx/website:$VER . && \
  git release $VER && \
  docker push cloudnativemx/website:$VER && docker push cloudnativemx/website:latest && docker push registry.circulosiete.com/library/cloudnativemx/website:$VER
