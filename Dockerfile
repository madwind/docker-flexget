FROM docker.io/python:3.9-alpine
ENV PYTHONUNBUFFERED 1

RUN \
    echo "**** install build packages ****" && \
    apk add --no-cache --upgrade \
        build-base \
        libffi-dev \
        openssl-dev \
        zlib-dev \
        jpeg-dev \
        freetype-dev \
        libpng-dev \
        rust \
        cargo

WORKDIR /wheels
RUN pip install -U pip && \
    pip wheel flexget && \
    pip wheel python-telegram-bot==12.8 && \
    pip wheel chardet && \
    pip wheel baidu-aip && \
    pip wheel pillow && \
    pip wheel pandas && \
    pip wheel matplotlib && \
    pip wheel fuzzywuzzy && \
    pip wheel python-Levenshtein && \
    pip wheel pyppeteer && \
    pip wheel pyppeteer_stealth

WORKDIR /flexget-ui-v2
RUN wget https://github.com/Flexget/webui/releases/latest/download/dist.zip && \
    unzip dist.zip && \
    rm dist.zip

FROM docker.io/python:3.9-alpine
LABEL maintainer="madwind.cn@gmail.com" \
      org.label-schema.name="flexget"
ENV PYTHONUNBUFFERED 1

RUN \
    echo "**** install runtime packages ****" && \
    apk add --no-cache \
        shadow \
        chromium \
        ca-certificates \
        tzdata && \
    rm -rf /var/cache/apk/*

COPY --from=0 /wheels /wheels
COPY --from=0 /flexget-ui-v2 /usr/local/lib/python3.9/site-packages/flexget/ui/v2/

RUN pip install -U pip && \
    pip install --no-cache-dir \
                --no-index \
                -f /wheels \
                flexget \
                python-telegram-bot==12.8 \
                chardet \
                baidu-aip \
                pillow \
                pandas \
                matplotlib \
                fuzzywuzzy \
                python-Levenshtein \
                pyppeteer \
                pyppeteer_stealth && \
    rm -rf /wheels

ADD link_chromium .

# add local files
COPY root/ /

RUN \
 echo "**** create abc user and make our folders ****" && \
 python link_chromium && \
 rm link_chromium && \
 groupmod -g 1000 users && \
 useradd -u 911 -U -d /home/flexget -s /bin/sh flexget && \
 usermod -G users flexget && \
 chown -R flexget:flexget /home/flexget && \
 chmod +x /usr/bin/entrypoint.sh

# add default volumes
VOLUME /config /downloads
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

ENTRYPOINT ["sh","-c","/usr/bin/entrypoint.sh"]
