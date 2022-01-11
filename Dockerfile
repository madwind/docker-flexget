FROM ubuntu
ENV PYTHONUNBUFFERED 1

RUN \
    echo "**** install build packages ****" && \
    apt-get update && \
    apt-get install -y gcc python

WORKDIR /wheels
RUN pip install -U pip && \
    pip wheel flexget && \
    pip wheel 'transmission-rpc>=3.0.0,<4.0.0' && \
    pip wheel python-telegram-bot==12.8 && \
    pip wheel chardet && \
    pip wheel baidu-aip && \
    pip wheel pillow && \
    pip wheel pandas && \
    pip wheel matplotlib && \
    pip wheel fuzzywuzzy && \
    pip wheel python-Levenshtein && \
    pip wheel playwright && \
    pip wheel cf-clearance


FROM ubuntu
LABEL maintainer="madwind.cn@gmail.com" \
      org.label-schema.name="flexget"
ENV PYTHONUNBUFFERED 1

COPY --from=0 /wheels /wheels
COPY root/ /

RUN \
    echo "**** install runtime packages ****" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
                    ca-certificates python &&\
                 #   libx11-xcb1 \
                 #   libxcomposite1 \
                 #   libxcursor1 \
                 #   libxdamage1 \
                 #   libxi6 \
                 #   libxtst6 \
                 #   libnss3 \
                 #   libcups2 \
                 #   libxrandr2 \
                 #   libasound2 \
                 #   libatk1.0-0 \
                 #   libatk-bridge2.0-0 \
                 #   libgtk-3-0 && \
    pip install -U pip && \
    pip install --no-cache-dir \
                --no-index \
                -f /wheels \
                flexget \
                'transmission-rpc>=3.0.0,<4.0.0' \
                python-telegram-bot==12.8 \
                chardet \
                baidu-aip \
                pillow \
                pandas \
                matplotlib \
                fuzzywuzzy \
                python-Levenshtein \
                playwright \
                cf-clearance && \
    echo "**** create flexget user and make our folders ****" && \
    mkdir /home/flexget && \
    groupmod -g 1000 users && \
    useradd -u 911 -U -d /home/flexget -s /bin/sh flexget && \
    usermod -G users flexget && \
    chown -R flexget:flexget /home/flexget && \
    su flexget -c "playwright install chromium && playwright install-deps" && \
    chmod +x /usr/bin/entrypoint.sh && \
    rm -rf /wheels \
           /var/lib/apt/lists/*

# add default volumes
VOLUME /config /downloads
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

ENTRYPOINT ["sh","-c","/usr/bin/entrypoint.sh"]
