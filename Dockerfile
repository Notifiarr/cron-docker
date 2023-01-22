FROM ubuntu:jammy@sha256:965fbcae990b0467ed5657caceaec165018ef44a4d2d46c7cdea80a9dff0d1ea

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && adduser --system --uid 99 --gid 100 --no-create-home --home / --disabled-login --disabled-password abc \
    && apt -y install --no-install-recommends software-properties-common gpg-agent cron \
    && apt-add-repository ppa:ondrej/php \
    && apt update
RUN apt install -y --no-install-recommends php8.0 php8.0-mysqli php8.0-memcached mysql-client
RUN apt purge -y software-properties-common gpg-agent python\* \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /etc/cron.*/*

ENTRYPOINT ["cron", "-f"]
