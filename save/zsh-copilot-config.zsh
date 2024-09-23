#!/usr/bin/env zsh

# Load user configuration
ZSH_COPILOT_DIR="${0:A:h}"
source "${ZSH_COPILOT_DIR}/zsh-copilot-user-config.zsh"

# Set default values if not defined in user config
typeset -gA ZSH_COPILOT_CONFIG
ZSH_COPILOT_CONFIG=(
    KEY "${ZSH_COPILOT_KEY:-'^z'}"
    SEND_CONTEXT "${ZSH_COPILOT_SEND_CONTEXT:-true}"
    DEBUG "${ZSH_COPILOT_DEBUG:-false}"
    LLM_PROVIDER "${ZSH_COPILOT_LLM_PROVIDER:-claude}"
    OPENAI_API_URL "${ZSH_COPILOT_OPENAI_API_URL:-https://api.openai.com/v1}"
    OPENAI_MODEL "${ZSH_COPILOT_OPENAI_MODEL:-gpt-4}"
    OLLAMA_URL "${ZSH_COPILOT_OLLAMA_URL:-http://localhost:11434}"
    OLLAMA_MODEL "${ZSH_COPILOT_OLLAMA_MODEL:-zsh}"
    GEMINI_API_URL "${ZSH_COPILOT_GEMINI_API_URL:-https://generativelanguage.googleapis.com/v1beta}"
    GEMINI_MODEL "${ZSH_COPILOT_GEMINI_MODEL:-gemini-1.5-pro}"
    MISTRAL_API_URL "${ZSH_COPILOT_MISTRAL_API_URL:-https://api.mistral.ai/v1}"
    MISTRAL_MODEL "${ZSH_COPILOT_MISTRAL_MODEL:-mistral-large-latest}"
    ANTHROPIC_API_URL "${ZSH_COPILOT_ANTHROPIC_API_URL:-https://api.anthropic.com/v1}"
    ANTHROPIC_MODEL "${ZSH_COPILOT_ANTHROPIC_MODEL:-claude-3-5-sonnet-20240620}"
)

# Debug configuration
ZSH_COPILOT_LOG_FILE="${ZSH_COPILOT_DIR}/zsh-copilot-debug.log"

# Enhanced debug function
function zsh_copilot_debug() {
    if [[ "${ZSH_COPILOT_CONFIG[DEBUG]}" == "true" ]]; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        local caller=${funcstack[2]:-main}
        echo "[$timestamp] [$caller] $1" >> "$ZSH_COPILOT_LOG_FILE"
    fi
}

# Initialize debug log
if [[ "${ZSH_COPILOT_CONFIG[DEBUG]}" == "true" ]]; then
    echo "" > "$ZSH_COPILOT_LOG_FILE"
    zsh_copilot_debug "Debug session started"
    zsh_copilot_debug "Plugin directory: $ZSH_COPILOT_DIR"
    zsh_copilot_debug "Log file path: $ZSH_COPILOT_LOG_FILE"
    zsh_copilot_debug "Configuration loaded"
fi

# API key validation functions
function check_api_key() {
    local provider=$1
    local api_key_var=$2
    local api_url=$3
    local endpoint=$4
    local headers=$5

    zsh_copilot_debug "Checking ${provider} API key"
    if [[ -z "${(P)api_key_var}" ]]; then
        zsh_copilot_debug "Warning: ${api_key_var} is not set"
        echo "Warning: ${api_key_var} is not set. ${provider} integration may not work."
        return 1
    fi

    zsh_copilot_debug "${api_key_var} is set (length: ${#${(P)api_key_var}})"
    local response=$(curl -s -o /dev/null -w "%{http_code}" $headers "${api_url}${endpoint}")
    
    zsh_copilot_debug "API response code: $response"
    if [[ "$response" != "200" ]]; then
        zsh_copilot_debug "Warning: ${api_key_var} seems to be invalid or there's a connection issue"
        echo "Warning: ${api_key_var} seems to be invalid or there's a connection issue."
        return 1
    else
        zsh_copilot_debug "${api_key_var} is valid"
        return 0
    fi
}

# API key checks
function check_openai_key() {
    check_api_key "OpenAI" "OPENAI_API_KEY" "${ZSH_COPILOT_CONFIG[OPENAI_API_URL]}" "/models" "-H \"Authorization: Bearer $OPENAI_API_KEY\""
}

function check_gemini_key() {
    check_api_key "Google Gemini" "GOOGLE_API_KEY" "${ZSH_COPILOT_CONFIG[GEMINI_API_URL]}" "/models?key=$GOOGLE_API_KEY" ""
}

function check_mistral_key() {
    check_api_key "Mistral" "MISTRAL_API_KEY" "${ZSH_COPILOT_CONFIG[MISTRAL_API_URL]}" "/models" "-H \"Authorization: Bearer $MISTRAL_API_KEY\""
}

function check_anthropic_key() {
    local response=$(curl -s -w "\n%{http_code}" \
        -H "x-api-key: $CLAUDE_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "content-type: application/json" \
        -d '{"model":"claude-3-sonnet-20240229","max_tokens":1,"messages":[{"role":"user","content":"Test"}]}' \
        "${ZSH_COPILOT_CONFIG[ANTHROPIC_API_URL]}/messages")
    
    local http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | sed '$d')
    
    zsh_copilot_debug "Anthropic API response code: $http_code"
    zsh_copilot_debug "Anthropic API response body: $response_body"
    
    if [[ "$http_code" != "200" ]]; then
        zsh_copilot_debug "Warning: CLAUDE_API_KEY seems to be invalid or there's a connection issue"
        echo "Warning: CLAUDE_API_KEY seems to be invalid or there's a connection issue."
        return 1
    else
        zsh_copilot_debug "CLAUDE_API_KEY is valid"
        echo "CLAUDE_API_KEY is valid and working."
        return 0
    fi
}

# Perform API key checks
if [[ -z "$ZSH_COPILOT_KEY_CHECKED" ]]; then
    case "${ZSH_COPILOT_CONFIG[LLM_PROVIDER]}" in
        "openai")   check_openai_key ;;
        "gemini")   check_gemini_key ;;
        "mistral")  check_mistral_key ;;
        "claude")   check_anthropic_key ;;
    esac
    export ZSH_COPILOT_KEY_CHECKED=1
    zsh_copilot_debug "API key check completed for ${ZSH_COPILOT_CONFIG[LLM_PROVIDER]}"
fi

# System prompt
zsh_copilot_debug "Loading system prompt"
read -r -d '' SYSTEM_PROMPT <<- EOM
You will be given the raw input of a shell command. 
Your task is to either complete the command or provide a new command that you think the user is trying to type. 
If you return a completely new command for the user, prefix it with an equal sign (=). 
If you return a completion for the user's command, prefix it with a plus sign (+). 
MAKE SURE TO ONLY INCLUDE THE REST OF THE COMPLETION!!! 
Do not write any leading or trailing characters except if required for the completion to work. 
Only respond with either a completion or a new command, not both. 
Your response may only start with either a plus sign or an equal sign.
Your response MAY NOT start with both! This means that your response IS NOT ALLOWED to start with '+=' or '=+'.
You MAY explain the command by writing a short line after the comment symbol (#).
Do not ask for more information, you won't receive it. 
Your response will be run in the user's shell. 
Make sure input is escaped correctly if needed so. 
Your input should be able to run without any modifications to it.
Don't you dare to return anything else other than a shell command!!! 
DO NOT INTERACT WITH THE USER IN NATURAL LANGUAGE! If you do, you will be banned from the system. 
Note that the double quote sign is escaped. Keep this in mind when you create quotes. 
Here are two examples: 
  * User input: 'list files in current directory'; Your response: '=ls # ls is the builtin command for listing files' 
  * User input: 'cd /tm'; Your response: '+p # /tmp is the standard temp folder on linux and mac'.
EOM
zsh_copilot_debug "System prompt loaded"

zsh_copilot_debug "Configuration and initialization completed successfully"