# Ubuntu 22. Renovate keeps the sha up to date.
FROM ubuntu:jammy@sha256:e9569c25505f33ff72e88b2990887c9dcf230f23259da296eb814fc2b41af999

# These can be changed, and the container runs usermod/groupmod to apply changes.
ENV PUID=99
ENV PGID=100
ENV TZ=America/New_York

# The user matches swag, where the website runs the same code that we run in crontabs.
# software-properties-common and gpg-agent are needed to run apt-add-repository.
RUN DEBIAN_FRONTEND=noninteractive apt update \
    && groupadd --system --non-unique --gid ${PGID} abc \
    && useradd --system --non-unique --uid ${PUID} --gid ${PGID} \
        --no-create-home --home-dir / --shell /usr/sbin/nologin abc \
    && apt -y install --no-install-recommends \
        cron supervisor tzdata ca-certificates software-properties-common gpg-agent \
    && apt-add-repository ppa:ondrej/php \
    && echo "TZ=${TZ}" >> /etc/environment \
    && echo "${TZ}" > /etc/timezone \
    && ([ ! -f "/usr/share/zoneinfo/${TZ}" ] \
    || ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime)

# This is where we install our custom packages we use in our crontabs.
ARG PHPVERS=8.1
ARG PHPMODS=cli,mysqli,curl,xml,memcached,mbstring,redis
ARG PACKAGES=mysql-client
RUN DEBIAN_FRONTEND=noninteractive apt update && /bin/bash -c \
    "apt install -y --no-install-recommends php${PHPVERS}-{${PHPMODS}} ${PACKAGES}"

# Clean up a few things. The cron changes are important.
RUN DEBIAN_FRONTEND=noninteractive apt purge -y software-properties-common gpg-agent \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /etc/cron.*/*

LABEL org.opencontainers.image.source = "https://github.com/Notifiarr/cron-docker"

COPY supervisor /etc/supervisor
COPY crontab /etc/crontab

ENTRYPOINT ["/etc/supervisor/init"]
