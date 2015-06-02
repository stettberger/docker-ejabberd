#!/bin/bash

echo ${EJABBERD_HOME}/database/${ERLANG_NODE}

chown ${EJABBERD_USER} ${EJABBERD_HOME}/database
if [ ! -e ${EJABBERD_HOME}/database/${ERLANG_NODE} ]; then
    mkdir ${EJABBERD_HOME}/database/${ERLANG_NODE}
    chown ${EJABBERD_USER} ${EJABBERD_HOME}/database/${ERLANG_NODE}
fi
