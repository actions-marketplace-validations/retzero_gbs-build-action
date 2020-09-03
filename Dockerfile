FROM docker:stable-dind

LABEL "name"="Tizen GBS Build Action"
LABEL "maintainer"="Hyokeun Jeon <hyokeun@gmail.com>"

LABEL "com.github.actions.name"="Tizen GBS Build"
LABEL "com.github.actions.description"="Build Tizen package"
LABEL "com.github.actions.icon"="box"
LABEL "com.github.actions.color"="green"

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git bash

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
