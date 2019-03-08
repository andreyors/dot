# ====================
# STAGE 1: base
# ====================
FROM ruby:2.6.1-alpine3.9 AS base

ENV CLIENT_DEPS git libcap ca-certificates bind-tools dumb-init
ENV BUILD_DEPS build-base cmake libxml2-dev libxslt-dev libffi-dev zlib-dev libressl-dev openssl-dev

RUN set -xe \
	&& apk add --update --no-cache ${CLIENT_DEPS} \
	&& apk add --virtual .build-deps ${BUILD_DEPS} \
	&& mkdir -p /src \
	&& rm -rf /var/cache/apk/*

WORKDIR /src/

# ====================
# STAGE 2: bundler
# ====================
FROM base AS bundler

COPY ./source/Gemfile* /src/

RUN set -xe \
	&& gem install bundler --update \
	&& bundle config --global silence_root_warning 1 \
	&& bundle config --global build.nokogiri --use-system-libraries \
	&& bundle config --global jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` \
	&& bundle config --global retry 6 \
	&& echo -e 'gem: --no-document' >> /etc/gemrc \
	&& bundle install \
	&& rm -rf /usr/local/bundle/cache/*.gem \
	&& find /usr/local/bundle/gems/ -name "*.c" -delete \
	&& find /usr/local/bundle/gems/ -name "*.o" -delete

FROM base AS dev

WORKDIR /src/

COPY ./source/ /src/
COPY --from=bundler /usr/local/bundle /usr/local/bundle

EXPOSE 8053
EXPOSE 8053/udp

CMD ["ash"]

# ====================
# STAGE 3: secure
# ====================
FROM base AS secure

WORKDIR /src/

COPY --from=bundler /usr/local/bundle /usr/local/bundle

RUN set -xe \
	&& setcap 'cap_net_raw+ep' /bin/busybox \
	&& setcap 'cap_net_raw+ep' /usr/local/bin/ruby \
	&& addgroup -g 1000 -S dot \
	&& adduser -u 1000 -S dot -G dot

COPY --chown=dot:dot ./source/ /src/

USER dot

EXPOSE 8053
EXPOSE 8053/udp

ENTRYPOINT ["dumb-init"]
CMD ["ruby", "bin/dot.rb", "run"]