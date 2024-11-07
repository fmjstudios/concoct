#syntax=docker/dockerfile:1.4

# Build arguments
#ARG VERSION=0.1.0
ARG PHP_VERSION=8.2

# pin versions
FROM dunglas/frankenphp:1-php$PHP_VERSION AS base

# container settings
ARG PHP_VERSION
ARG PUID=1001
ARG PGID=1001
ARG PORT=3456
ARG USER=concoctl

# encforce FrankenPHP working dir
WORKDIR /app

# prepare for volumes
VOLUME ["/app/var"]

# persistent / runtime deps
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
	acl \
	file \
	gettext \
	git \
    sqlite3 \
    libsqlite3-dev \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install `install-php-extensions` to install extensions (and composer) with all dependencies included
# install Shopware required PHP extensions and the latest version of Composer
# ref: https://github.com/mlocati/docker-php-extension-installer
# ref: https://developer.shopware.com/docs/guides/installation/requirements.html
RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions \
    @composer \
    apcu \
    intl \
    opcache \
    zip

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

COPY --link --chown=${PUID}:${PGID} docker/conf/php/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chown=${PUID}:${PGID} --chmod=755 docker/bin/concoctl /usr/local/bin
COPY --link --chown=${PUID}:${PGID} --chmod=755 docker/lib/utils.sh /usr/local/lib
COPY --link --chown=${PUID}:${PGID} docker/conf/caddy/Caddyfile /etc/caddy/Caddyfile

# set default environment
ENV APP_ENV=dev \
    XDEBUG_MODE=off

ENTRYPOINT ["concoctl", "run"]

# add a healthcheck
# ref: https://developer.shopware.com/docs/guides/hosting/installation-updates/cluster-setup.html#health-check
HEALTHCHECK --start-period=60s CMD curl -f http://localhost:3456/metrics || exit 1
CMD [ "frankenphp", "run", "--config", "/etc/caddy/Caddyfile" ]

# -------------------------------------
# DEVELOPMENT Image
# -------------------------------------
FROM base AS dev

# (re)-set args
ARG PUID
ARG PGID

ENV APP_ENV=dev \
    XDEBUG_MODE=off

# add xdebug in DEV mode
RUN install-php-extensions xdebug

# copy sources
COPY --link --chown=${PUID}:${PGID} . /app

# copy development configs
COPY --link --chown=${PUID}:${PGID} docker/conf/php/20-app.dev.ini $PHP_INI_DIR/app.conf.d/
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile", "--watch"]


# -------------------------------------
# PRODUCTION Image
# -------------------------------------
FROM base AS prod

# (re)-set args
ARG PUID
ARG PGID

ENV APP_ENV=prod \
    FRANKENPHP_CONFIG="import worker.Caddyfile"

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# copy production configs
COPY --link --chown=${PUID}:${PGID} docker/conf/php/20-app.prod.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chown=${PUID}:${PGID} docker/conf/caddy/worker.Caddyfile /etc/caddy/worker.Caddyfile

# prevent the reinstallation of vendors at every changes in the source code
COPY --link composer.* symfony.* ./
RUN set -eux; \
	composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

# copy sources & remove non-ignorable directories
COPY --link --chown=${PUID}:${PGID} . /app
RUN rm -Rf docker/

# prepare sources
RUN set -eux; \
	mkdir -p var/cache var/log; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	composer dump-env prod; \
	composer run-script --no-dev post-install-cmd; \
	chmod +x bin/console; sync;

# create non-root user
ARG USER
RUN \
	# Use "adduser -D ${USER}" for alpine based distros
	useradd ${USER}; \
	# Remove default capability
	setcap -r /usr/local/bin/frankenphp; \
	# Give write access to /data/caddy and /config/caddy
	chown -R ${USER}:${USER} /data/caddy && chown -R ${USER}:${USER} /config/caddy

# own files
RUN find /app -type f -exec chmod 644 {} + && \
    find /app -type d -exec chmod 755 {} + && \
    setfacl -R -m u:${USER}:rwX -m u:${USER}:rwX /app/var && \
    setfacl -dR -m u:${USER}:rwX -m u:${USER}:rwX /app/var && \
    chown -R $PUID:$PGID /app

# expose 3456
EXPOSE $PORT



USER ${USER}
