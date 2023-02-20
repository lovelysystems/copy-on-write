FROM alpine:3.17.2
RUN apk add --no-cache bash
RUN apk add --no-cache inotify-tools

COPY ./start-copying.sh /

RUN chmod +x /start-copying.sh

ENTRYPOINT ["/start-copying.sh"]