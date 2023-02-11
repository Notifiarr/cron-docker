# Ubuntu 22. Renovate keeps the sha up to date.
FROM ubuntu:jammy@sha256:c985bc3f77946b8e92c9a3648c6f31751a7dd972e06604785e47303f4ad47c4c

# These can be changed, and the container runs usermod/groupmod to apply changes.
ENV PUID=99
ENV PGID=100

# The user matches swag, where the website runs the same code that we run in crontabs.
# software-properties-common and gpg-agent are needed to run apt-add-repository.
RUN DEBIAN_FRONTEND=noninteractive apt update \
    && groupadd --system --non-unique --gid ${PGID} abc \
    && useradd --system --non-unique --uid ${PUID} --gid ${PGID} \
        --no-create-home --home-dir / --shell /usr/sbin/nologin abc \
    && apt -y install --no-install-recommends \
        cron supervisor tzdata ca-certificates software-properties-common gpg-agent \
    && apt-add-repository ppa:ondrej/php

# This is where we install our custom packages we use in our crontabs.
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y --no-install-recommends \
    php8.1-cli php8.1-mysqli php8.1-memcached mysql-client

# Clean up a few things. The cron changes are important.
RUN DEBIAN_FRONTEND=noninteractive apt purge -y software-properties-common gpg-agent \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /etc/cron.*/*

LABEL org.opencontainers.image.source = "https://github.com/Notifiarr/cron-docker"

COPY supervisor /etc/supervisor
COPY crontab /etc/crontab
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
