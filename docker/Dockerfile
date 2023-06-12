FROM alpine:3.16.5
#do NOT upgrade alpine version, alpine 3.17.0, the version needed for inotify-tools isn't available
RUN apk add --no-cache bash && apk add --no-cache inotify-tools

COPY ./docker-entrypoint.sh /

RUN chmod 750 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
