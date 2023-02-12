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

You must mount a folder at `/config/log` to capture log files.
The other two folders shown here are optional depending on what you want to do.
Put crons into `/config/cron` and put supervisor configs into `/config/supervisor`.

```
docker run -d \
    --name cron \
    -v /host/logs:/config/log:rw \
    -v /host/cron.d:/config/cron:ro \
    -v /host/supervisor.d:/config/supervisor:ro \
    ghcr.io/notifiarr/cron-docker:main
```

### Configuration

Available variables that control things in the container. Setting a username and
password is recommended. The password may be SHA1 encoded if it begins with the
string `{SHA}`. Read more [here](http://supervisord.org/configuration.html#inet-http-server-section-settings).

You can use the `abc` user however you want. Set its user ID and group ID to
avoid perissions problems with your crontabs.

| Variable        | Default          | Purpose                             |
| --------------- | ---------------- | ----------------------------------- |
| PUID            | 99               | Controls the `abc` user UID         |
| PGID            | 100              | Controls the `abc` user GID         |
| TZ              | America/New_York | Sets the time zone in the container |
| SUPERVISOR_PORT | 9911             | Sets the XML RPC interface TCP port |
| SUPERVISOR_USER | `""`  (empty)    | Sets the XML RPC interface username |
| SUPERVISOR_PASS | `""`  (empty)    | Sets the XML RPC interface password |