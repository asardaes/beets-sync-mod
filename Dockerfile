# syntax=docker/dockerfile:1

FROM alpine AS tmpstage

COPY root/ /fakeroot/

ENV GOSU_VERSION=1.17
RUN set -eux; \
	\
	apk add --no-cache \
		ca-certificates \
		dpkg \
		gnupg \
	; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /fakeroot/usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /fakeroot/usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	gpg --batch --verify /fakeroot/usr/local/bin/gosu.asc /fakeroot/usr/local/bin/gosu; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /fakeroot/usr/local/bin/gosu.asc; \
	chmod +x /fakeroot/usr/local/bin/gosu

FROM scratch

LABEL maintainer="asardaes"

# copy local files
COPY --from=tmpstage /fakeroot/ /
