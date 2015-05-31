#!/bin/bash

source "${EJABBERD_HOME}/scripts/lib/base_config.sh"
source "${EJABBERD_HOME}/scripts/lib/config.sh"
source "${EJABBERD_HOME}/scripts/lib/base_functions.sh"
source "${EJABBERD_HOME}/scripts/lib/functions.sh"

run_scripts() {
    local run_script_dir="${EJABBERD_HOME}/scripts/${1}"
    for script in ${run_script_dir}/*.sh ; do
        if [ -f ${script} -a -x ${script} ] ; then
            ${script}
        fi
    done
}


post_scripts() {
    run_scripts "post"
}

ctl() {
    local action="$1"
    ${EJABBERDCTL} ${action} >/dev/null
}


_trap() {
    echo "Stopping ejabberd..."
    if ctl stop ; then
        local cnt=0
        sleep 1
        while ctl status || test $? = 1 ; do
            cnt=`expr $cnt + 1`
            if [ $cnt -ge 60 ] ; then
                break
            fi
            sleep 1
        done
    fi
}

# Catch signals and shutdown ejabberd
trap _trap SIGTERM SIGINT

# Show all logfiles
touch ${LOGDIR}/crash.log ${LOGDIR}/error.log ${LOGDIR}/erlang.log
tail -F ${LOGDIR}/crash.log \
        ${LOGDIR}/error.log \
        ${LOGDIR}/erlang.log &

echo "Starting ejabberd..."
exec  ${EJABBERDCTL} "live" &
child=$!
${EJABBERDCTL} "started"
post_scripts
wait $child
