# Ubuntu 22. Renovate keeps the sha up to date.
FROM ubuntu:jammy@sha256:965fbcae990b0467ed5657caceaec165018ef44a4d2d46c7cdea80a9dff0d1ea

# These can be changed, and the container runs usermod/groupmod to apply changes.
ENV PUID=99
ENV PGID=100

# The user matches swag, where the website runs the same code that we run in crontabs.
# software-properties-common and gpg-agent are needed to run apt-add-repository.
RUN DEBIAN_FRONTEND=noninteractive apt update \
    && groupadd --system --non-unique --gid ${PGID} abc \
    && useradd --system --non-unique --uid ${PUID} --gid ${PGID} \
        --no-create-home --home-dir / --shell /usr/sbin/nologin abc \
    && apt -y install --no-install-recommends software-properties-common gpg-agent cron supervisor \
    && apt-add-repository ppa:ondrej/php \
    && apt update

# This is where we install our custom packages we use in our crontabs.
RUN DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    php8.0 php8.0-mysqli php8.0-memcached mysql-client

# Clean up a few things. The cron changes are important.
RUN DEBIAN_FRONTEND=noninteractive apt purge -y software-properties-common gpg-agent \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /etc/cron.*/* /etc/cron.d \
    && ln -s /config/cron /etc/cron.d

LABEL org.opencontainers.image.source = "https://github.com/Notifiarr/cron-docker"

COPY supervisor /etc/supervisor
COPY crontab /etc/crontab
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
