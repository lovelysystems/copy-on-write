FROM alpine:3.18.0
RUN apk add --no-cache bash && apk add --no-cache inotify-tools

COPY ./docker-entrypoint.sh /

RUN chmod 750 /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
