#!/usr/bin/env zsh

function get_system_info() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Your system is ${$(sw_vers | xargs | sed 's/ /./g')}."
    else 
        echo "Your system is ${$(cat /etc/*-release | xargs | sed 's/ /,/g')}."
    fi
}

function debug_log() {
    if [[ "$ZSH_COPILOT_DEBUG" == 'true' ]]; then
        local input=$1
        local response=$2
        local first_char=$3
        local suggestion=$4
        local data=$5
        
        touch /tmp/zsh-copilot.log
        echo "$(date);INPUT:$input;RESPONSE:$response;FIRST_CHAR:$first_char;SUGGESTION:$suggestion:DATA:$data" >> /tmp/zsh-copilot.log
    fi
}

SYSTEM=$(get_system_info)