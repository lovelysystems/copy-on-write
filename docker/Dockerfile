FROM alpine:3.16.4
#do NOT upgrad alpine version, alpine 3.17.0, the version needed for inotify-tools isnt available

RUN apk add --no-cache bash
RUN apk add --no-cache inotify-tools

COPY ./docker-entrypoint.sh /

RUN chmod 750 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]