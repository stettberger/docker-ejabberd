#!/bin/bash
set -e


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


run_scripts pre

exec /sbin/setuser ${EJABBERD_USER} ${EJABBERD_HOME}/run.sh
