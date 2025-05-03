# syntax=docker/dockerfile:1

FROM scratch

LABEL maintainer="asardae"

# copy local files
COPY root/ /
