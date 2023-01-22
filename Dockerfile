# Ubuntu 22. Renovate keeps the sha up to date.
FROM ubuntu:jammy@sha256:965fbcae990b0467ed5657caceaec165018ef44a4d2d46c7cdea80a9dff0d1ea

ENV DEBIAN_FRONTEND noninteractive

# The user matches swag, where the website runs the same code that we run in crontabs.
# software-properties-common and gpg-agent are needed to run apt-add-repository.
RUN apt update \
    && adduser --system --uid 99 --gid 100 --no-create-home --home / --disabled-login --disabled-password abc \
    && apt -y install --no-install-recommends software-properties-common gpg-agent cron \
    && apt-add-repository ppa:ondrej/php \
    && apt update

# This is where we install our custom packages we use in our crontabs.
RUN apt install -y --no-install-recommends \
    php8.0 php8.0-mysqli php8.0-memcached mysql-client

# This cleanup saves a few megabytes on the image, but isn't terribly critical or important.
RUN apt purge -y software-properties-common gpg-agent python\* \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /etc/cron.*/*

LABEL org.opencontainers.image.source = "https://github.com/Notifiarr/cron-docker"

ENTRYPOINT ["cron", "-f"]
