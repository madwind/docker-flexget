FROM python:slim
ENV PYTHONUNBUFFERED 1

#RUN \
#    echo "**** install build packages ****" && \
#    apk add --no-cache --upgrade \
#        build-base \
#        libffi-dev \
#        openssl-dev \
#        zlib-dev \
#        jpeg-dev \
#        freetype-dev \
#        libpng-dev \
#        rust \
#        cargo

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


FROM python:slim
LABEL maintainer="madwind.cn@gmail.com" \
      org.label-schema.name="flexget"
ENV PYTHONUNBUFFERED 1

COPY --from=0 /wheels /wheels
ADD link_chromium .
COPY root/ /

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update &&
    apt-get install -y --no-install-recommends \
        chromium \
        ca-certificates && \
    pip install -U pip && \
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
    echo "**** create abc user and make our folders ****" && \
    python link_chromium && \
    rm link_chromium && \
    groupmod -g 1000 users && \
    useradd -u 911 -U -d /home/flexget -s /bin/sh flexget && \
    usermod -G users flexget && \
    chown -R flexget:flexget /home/flexget && \
    chmod +x /usr/bin/entrypoint.sh && \
    rm -rf /wheels \
           /var/lib/apt/lists/*

# add default volumes
VOLUME /config /downloads
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

ENTRYPOINT ["sh","-c","/usr/bin/entrypoint.sh"]
