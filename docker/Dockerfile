FROM alpine:3.16.4
#do NOT upgrad alpine version, alpine 3.17.0, the version needed for inotify-tools isnt available

RUN apk add --no-cache bash
RUN apk add --no-cache "inotify-tools=3.20.11.0-r0"

RUN apk update
RUN apk --update upgrade

#RUN apk --update upgrade && apk add --update inotify-tools && rm -rf /var/cache/apk/*

COPY ./start-copying.sh /

RUN chmod 750 /start-copying.sh

ENTRYPOINT ["/start-copying.sh"]