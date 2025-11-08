ARG BUILD_FROM
FROM ${BUILD_FROM}

ENV LANG C.UTF-8

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    xvfb \
    tigervnc \
    fluxbox \
    xterm \
    supervisor \
    novnc

COPY WinBox /usr/bin/WinBox
RUN chmod a+x /usr/bin/WinBox

RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY run.sh /
RUN chmod a+x /run.sh

EXPOSE 8099

CMD [ "/run.sh" ]