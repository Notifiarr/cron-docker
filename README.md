# cron-docker
Simple docker container that runs crontab and has php installed.

It also runs supervisor so you can drop in other tasks real easy.
An [example PHP worker](https://github.com/Notifiarr/cron-docker/blob/main/supervisor/conf.d/php.worker) is provided.

# Use

This thing fits our needs, but if you want to try it, feel free.

### Image

```
docker pull ghcr.io/notifiarr/cron-docker:main
```

### Example

You should definitely mount something at `/var/log/supervisor` to capture log files.
The other two folders shown here are optional depending on what you want to do.
Put crons into `/config/cron` and put supervisor configs into `/config/supervisor`.

```
docker run -d \
    --name cron \
    -v /host/logs:/var/log/supervisor:rw \
    -v /host/cron.d:/config/cron:ro \
    -v /host/supervisor.d:/config/supervisor:ro \
    ghcr.io/notifiarr/cron-docker:main
```