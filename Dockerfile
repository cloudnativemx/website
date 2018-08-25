FROM jojomi/hugo:0.47 AS build-env

WORkDIR /app
COPY ./site ./

RUN sh -c './build.sh'

# build runtime image
FROM nginx:1.15.2-alpine

COPY --from=build-env /app/public/ /www/cloudnative.mx/public/
COPY conf/nginx/* /etc/nginx/conf.d