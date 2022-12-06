FROM debian:stable
RUN apt update -y && apt upgrade -y && apt install curl fish libasound2 build-essential clang -y

ENV NIGHTLY_VERSION=2022-12-06-c8a335c
ENV DOWNLOAD_FILE=roc_nightly-linux_x86_64-${NIGHTLY_VERSION}.tar.gz

RUN curl -OL https://github.com/roc-lang/roc/releases/download/nightly/${DOWNLOAD_FILE} \
    && tar -xzf ${DOWNLOAD_FILE} \
    && rm ${DOWNLOAD_FILE} \
    && mv roc /usr/local/bin/roc

RUN mkdir /app
WORKDIR /app

CMD fish