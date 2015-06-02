FROM phusion/baseimage
MAINTAINER Christian Dietrich <stettberger@dokucode.de>

ENV EJABBERD_BRANCH 15.04
ENV EJABBERD_USER ejabberd
ENV EJABBERD_WEB_ADMIN_SSL true
ENV EJABBERD_STARTTLS true
ENV EJABBERD_S2S_SSL true
ENV EJABBERD_HOME /opt/ejabberd
ENV HOME $EJABBERD_HOME
ENV PATH $EJABBERD_HOME/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV DEBIAN_FRONTEND noninteractive
ENV XMPP_DOMAIN jabber.zerties.org
ENV ERLANG_NODE ejabberd@localhost
env TZ Europe/Berlin

# Add ejabberd user and group
RUN groupadd -r $EJABBERD_USER \
    && useradd -r -m \
       -g $EJABBERD_USER \
       -d $EJABBERD_HOME \
       -s /bin/bash \
       $EJABBERD_USER

ADD ./erlang_solutions.asc /tmp/erlang_solutions.asc

# Install erlang
RUN echo 'deb https://packages.erlang-solutions.com/debian wheezy contrib' >> /etc/apt/sources.list \
    && apt-key add /tmp/erlang_solutions.asc \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends  -yq install \
        locales \
        curl \
        git-core \
        build-essential \
        automake \
        libssl-dev \
        libyaml-dev \
        zlib1g-dev \
        libexpat-dev \
        python2.7 \
        python-jinja2 \
        ca-certificates \
        libsqlite3-dev \
        erlang-base \
        erlang-snmp erlang-ssl erlang-ssh erlang-webtool erlang-tools \
        erlang-xmerl erlang-corba erlang-diameter erlang-eldap \
        erlang-eunit erlang-ic erlang-inviso erlang-odbc erlang-os-mon \
        erlang-parsetools erlang-percept erlang-typer erlang-src \
        erlang-dev \
    && rm /tmp/erlang_solutions.asc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && cd /tmp \
    && git clone https://github.com/processone/ejabberd.git \
        --branch $EJABBERD_BRANCH --single-branch --depth=1 \
    && cd ejabberd \
    && chmod +x ./autogen.sh \
    && ./autogen.sh \
    && ./configure --enable-user=$EJABBERD_USER \
        --enable-all \
        --disable-tools \
        --disable-pam \
    && make \
    && make install \
    && mkdir $EJABBERD_HOME/ssl \
    && mkdir $EJABBERD_HOME/conf \
    && mkdir $EJABBERD_HOME/database \
    && cd $EJABBERD_HOME \
    && rm -rf /tmp/ejabberd \
    && rm -rf /etc/ejabberd \
    && ln -sf $EJABBERD_HOME/conf /etc/ejabberd \
    && chown -R $EJABBERD_USER: $EJABBERD_HOME

# Add run scripts
ADD ./scripts $EJABBERD_HOME/scripts

# The service file (which switches to ejabberd user), and the actual daemon starting script
ADD ./ejabberd-service.sh /etc/service/ejabberd/run
ADD ./run.sh ${EJABBERD_HOME}/run.sh

# Add config templates
ADD ./conf /opt/ejabberd/conf

VOLUME ["/opt/ejabberd/database", "$EJABBERD_HOME/ssl"]
EXPOSE 4560 5222 5269 5280
