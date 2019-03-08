FROM ruby:2.6.1-alpine3.9 AS build-env

ENV BUILD_DEPS ca-certificates
ENV DEV_DEPS build-base cmake libxml2-dev libxslt-dev libffi-dev zlib-dev libressl-dev

WORKDIR /src/

COPY ./source/Gemfile* /src/

RUN set -xe \
	&& apk add --no-cache ${BUILD_DEPS} ${DEV_DEPS} \
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

FROM ruby:2.6.1-alpine3.9 AS dev

WORKDIR /src/

COPY ./source/ /src/
COPY --from=build-env /usr/local/bundle /usr/local/bundle

EXPOSE 8053
EXPOSE 8053/udp

CMD ["ash"]

FROM ruby:2.6.1-alpine3.9 AS prod

WORKDIR /src/

RUN set -xe \
	&& addgroup -g 1000 -S dot \
	&& adduser -u 1000 -S dot -G dot

COPY --chown=dot:dot ./source/ /src/
COPY --from=build-env /usr/local/bundle /usr/local/bundle

USER dot

EXPOSE 8053
EXPOSE 8053/udp

CMD ["ruby", "bin/dot.rb", "start"]