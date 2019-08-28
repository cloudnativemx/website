FROM jojomi/hugo:0.57.2 AS build-env

WORkDIR /app
COPY ./site ./

RUN sh -c './build.sh'

# build runtime image
FROM nginx:1.17.3-alpine

#COPY --from=build-env /app/public/ /www/cloudnative.mx/public/
#COPY conf/nginx/* /etc/nginx/conf.d

COPY --from=build-env /app/public/ /usr/share/nginx/html