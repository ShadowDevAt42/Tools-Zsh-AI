#!/usr/bin/env zsh

zsh_copilot_debug "Loading zsh-copilot-utils.zsh"

function get_system_info() {
    zsh_copilot_debug "Getting system info"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        local system_info=$(sw_vers | xargs | sed 's/ /./g')
        zsh_copilot_debug "Detected macOS system: $system_info"
        echo "Your system is ${system_info}."
    else 
        local system_info=$(cat /etc/*-release | xargs | sed 's/ /,/g')
        zsh_copilot_debug "Detected Linux system: $system_info"
        echo "Your system is ${system_info}."
    fi
}

function debug_log() {
    if [[ "$ZSH_COPILOT_DEBUG" == 'true' ]]; then
        local input=$1
        local response=$2
        local first_char=$3
        local suggestion=$4
        local data=$5
        
        zsh_copilot_debug "DEBUG LOG:"
        zsh_copilot_debug "INPUT: $input"
        zsh_copilot_debug "RESPONSE: $response"
        zsh_copilot_debug "FIRST_CHAR: $first_char"
        zsh_copilot_debug "SUGGESTION: $suggestion"
        zsh_copilot_debug "DATA: $data"
    fi
}

SYSTEM=$(get_system_info)
zsh_copilot_debug "System info: $SYSTEM"

zsh_copilot_debug "zsh-copilot-utils.zsh loaded successfully"