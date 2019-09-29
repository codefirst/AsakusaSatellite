FROM ruby:2.3.0

WORKDIR /tmp

RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.6-linux-x86_64.tar.bz2 &&  \
    bzip2 -dc phantomjs-1.9.6-linux-x86_64.tar.bz2 | tar xvf - && \
    mv phantomjs-1.9.6-linux-x86_64/bin/phantomjs /usr/local/bin && \
    rm -rf phantomjs-1.9.6-linux-x86_64.tar.bz2.tar.bz2 phantomjs-1.9.6-linux-x86_64

RUN mkdir -p /work

WORKDIR /work
