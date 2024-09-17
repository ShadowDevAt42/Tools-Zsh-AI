# Configuration variables
(( ! ${+ZSH_COPILOT_KEY} )) && typeset -g ZSH_COPILOT_KEY='^z'
(( ! ${+ZSH_COPILOT_SEND_CONTEXT} )) && typeset -g ZSH_COPILOT_SEND_CONTEXT=true
(( ! ${+ZSH_COPILOT_DEBUG} )) && typeset -g ZSH_COPILOT_DEBUG=true

# Get the plugin directory
ZSH_COPILOT_DIR="${0:A:h}"

# Set log file path
ZSH_COPILOT_LOG_FILE="${ZSH_COPILOT_DIR}/zsh-copilot-debug.log"

# Debug function
function zsh_copilot_debug() {
    if [[ "$ZSH_COPILOT_DEBUG" == "true" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$ZSH_COPILOT_LOG_FILE"
    fi
}

# Clear log file if debug is active
if [[ "$ZSH_COPILOT_DEBUG" == "true" ]]; then
    echo "" > "$ZSH_COPILOT_LOG_FILE"
    zsh_copilot_debug "Log file cleared and debug session started."
fi

zsh_copilot_debug "Plugin directory: $ZSH_COPILOT_DIR"
zsh_copilot_debug "Log file path: $ZSH_COPILOT_LOG_FILE"
zsh_copilot_debug "Loading configuration..."

# LLM configuration
(( ! ${+ZSH_COPILOT_LLM_PROVIDER} )) && typeset -g ZSH_COPILOT_LLM_PROVIDER="claude"
zsh_copilot_debug "LLM Provider: $ZSH_COPILOT_LLM_PROVIDER"

# OpenAI configuration
(( ! ${+ZSH_COPILOT_OPENAI_API_URL} )) && typeset -g ZSH_COPILOT_OPENAI_API_URL="https://api.openai.com/v1"
(( ! ${+ZSH_COPILOT_OPENAI_MODEL} )) && typeset -g ZSH_COPILOT_OPENAI_MODEL="gpt-4"
zsh_copilot_debug "OpenAI API URL: $ZSH_COPILOT_OPENAI_API_URL"
zsh_copilot_debug "OpenAI Model: $ZSH_COPILOT_OPENAI_MODEL"

# Ollama configuration
(( ! ${+ZSH_COPILOT_OLLAMA_URL} )) && typeset -g ZSH_COPILOT_OLLAMA_URL="http://localhost:11434"
(( ! ${+ZSH_COPILOT_OLLAMA_MODEL} )) && typeset -g ZSH_COPILOT_OLLAMA_MODEL="zsh"
zsh_copilot_debug "Ollama URL: $ZSH_COPILOT_OLLAMA_URL"
zsh_copilot_debug "Ollama Model: $ZSH_COPILOT_OLLAMA_MODEL"

# API Keys check
function check_openai_key() {
    zsh_copilot_debug "Checking OpenAI API key"
    if [[ -z "${OPENAI_API_KEY}" ]]; then
        zsh_copilot_debug "Warning: OPENAI_API_KEY is not set"
        echo "Warning: OPENAI_API_KEY is not set. OpenAI integration may not work."
    else
        zsh_copilot_debug "OPENAI_API_KEY is set (length: ${#OPENAI_API_KEY})"
        local response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            "${ZSH_COPILOT_OPENAI_API_URL}/models")
        
        zsh_copilot_debug "API response code: $response"
        if [[ "$response" != "200" ]]; then
            zsh_copilot_debug "Warning: OPENAI_API_KEY seems to be invalid or there's a connection issue"
            echo "Warning: OPENAI_API_KEY seems to be invalid or there's a connection issue."
        else
            zsh_copilot_debug "OPENAI_API_KEY is valid"
        fi
    fi
}

# Only check the API key when the plugin is loaded
if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "openai" && -z "$ZSH_COPILOT_KEY_CHECKED" ]]; then
    zsh_copilot_debug "Initiating API key check"
    check_openai_key
    export ZSH_COPILOT_KEY_CHECKED=1
    zsh_copilot_debug "API key check completed"
fi

# Google Gemini configuration
(( ! ${+ZSH_COPILOT_GEMINI_API_URL} )) && typeset -g ZSH_COPILOT_GEMINI_API_URL="https://generativelanguage.googleapis.com/v1beta"
(( ! ${+ZSH_COPILOT_GEMINI_MODEL} )) && typeset -g ZSH_COPILOT_GEMINI_MODEL="gemini-1.5-pro"
zsh_copilot_debug "Google Gemini API URL: $ZSH_COPILOT_GEMINI_API_URL"
zsh_copilot_debug "Google Gemini Model: $ZSH_COPILOT_GEMINI_MODEL"

# API Keys check
function check_gemini_key() {
    zsh_copilot_debug "Checking Google Gemini API key"
    if [[ -z "${GOOGLE_API_KEY}" ]]; then
        zsh_copilot_debug "Warning: GOOGLE_API_KEY is not set"
        echo "Warning: GOOGLE_API_KEY is not set. Google Gemini integration may not work."
    else
        zsh_copilot_debug "GOOGLE_API_KEY is set (length: ${#GOOGLE_API_KEY})"
        local response=$(curl -s -o /dev/null -w "%{http_code}" \
            "${ZSH_COPILOT_GEMINI_API_URL}/models?key=$GOOGLE_API_KEY")
        
        zsh_copilot_debug "API response code: $response"
        if [[ "$response" != "200" ]]; then
            zsh_copilot_debug "Warning: GOOGLE_API_KEY seems to be invalid or there's a connection issue"
            echo "Warning: GOOGLE_API_KEY seems to be invalid or there's a connection issue."
        else
            zsh_copilot_debug "GOOGLE_API_KEY is valid"
        fi
    fi
}

# Only check the API key when the plugin is loaded
if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "gemini" && -z "$ZSH_COPILOT_KEY_CHECKED" ]]; then
    zsh_copilot_debug "Initiating API key check for Google Gemini"
    check_gemini_key
    export ZSH_COPILOT_KEY_CHECKED=1
    zsh_copilot_debug "API key check completed for Google Gemini"
fi

# Mistral configuration
(( ! ${+ZSH_COPILOT_MISTRAL_API_URL} )) && typeset -g ZSH_COPILOT_MISTRAL_API_URL="https://api.mistral.ai/v1"
(( ! ${+ZSH_COPILOT_MISTRAL_MODEL} )) && typeset -g ZSH_COPILOT_MISTRAL_MODEL="mistral-large-latest"
zsh_copilot_debug "Mistral API URL: $ZSH_COPILOT_MISTRAL_API_URL"
zsh_copilot_debug "Mistral Model: $ZSH_COPILOT_MISTRAL_MODEL"

# API Keys check for Mistral
function check_mistral_key() {
    zsh_copilot_debug "Checking Mistral API key"
    if [[ -z "${MISTRAL_API_KEY}" ]]; then
        zsh_copilot_debug "Warning: MISTRAL_API_KEY is not set"
        echo "Warning: MISTRAL_API_KEY is not set. Mistral integration may not work."
    else
        zsh_copilot_debug "MISTRAL_API_KEY is set (length: ${#MISTRAL_API_KEY})"
        local response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer $MISTRAL_API_KEY" \
            "${ZSH_COPILOT_MISTRAL_API_URL}/models")
        
        zsh_copilot_debug "API response code: $response"
        if [[ "$response" != "200" ]]; then
            zsh_copilot_debug "Warning: MISTRAL_API_KEY seems to be invalid or there's a connection issue"
            echo "Warning: MISTRAL_API_KEY seems to be invalid or there's a connection issue."
        else
            zsh_copilot_debug "MISTRAL_API_KEY is valid"
        fi
    fi
}

# Only check the API key when the plugin is loaded
if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "mistral" && -z "$ZSH_COPILOT_KEY_CHECKED" ]]; then
    zsh_copilot_debug "Initiating API key check for Mistral"
    check_mistral_key
    export ZSH_COPILOT_KEY_CHECKED=1
    zsh_copilot_debug "API key check completed for Mistral"
fi

# Anthropic configuration
(( ! ${+ZSH_COPILOT_ANTHROPIC_API_URL} )) && typeset -g ZSH_COPILOT_ANTHROPIC_API_URL="https://api.anthropic.com/v1"
(( ! ${+ZSH_COPILOT_ANTHROPIC_MODEL} )) && typeset -g ZSH_COPILOT_ANTHROPIC_MODEL="claude-3-5-sonnet-20240620"
zsh_copilot_debug "Anthropic API URL: $ZSH_COPILOT_ANTHROPIC_API_URL"
zsh_copilot_debug "Anthropic Model: $ZSH_COPILOT_ANTHROPIC_MODEL"

# API Keys check for Anthropic
function check_anthropic_key() {
    zsh_copilot_debug "Checking Anthropic API key"
    if [[ -z "${CLAUDE_API_KEY}" ]]; then
        zsh_copilot_debug "Warning: CLAUDE_API_KEY is not set"
        echo "Warning: CLAUDE_API_KEY is not set. Anthropic integration may not work."
    else
        zsh_copilot_debug "CLAUDE_API_KEY is set (length: ${#CLAUDE_API_KEY})"
        local response=$(curl -s -w "\n%{http_code}" \
            -H "x-api-key: $CLAUDE_API_KEY" \
            -H "anthropic-version: 2023-06-01" \
            -H "content-type: application/json" \
            -d '{"model":"claude-3-sonnet-20240229","max_tokens":1,"messages":[{"role":"user","content":"Test"}]}' \
            "${ZSH_COPILOT_ANTHROPIC_API_URL}/messages")
        
        local http_code=$(echo "$response" | tail -n1)
        local response_body=$(echo "$response" | sed '$d')
        
        zsh_copilot_debug "API response code: $http_code"
        zsh_copilot_debug "API response body: $response_body"
        
        if [[ "$http_code" != "200" ]]; then
            zsh_copilot_debug "Warning: CLAUDE_API_KEY seems to be invalid or there's a connection issue"
            echo "Warning: CLAUDE_API_KEY seems to be invalid or there's a connection issue."
        else
            zsh_copilot_debug "CLAUDE_API_KEY is valid"
            echo "CLAUDE_API_KEY is valid and working."
        fi
    fi
}

# Only check the API key when the plugin is loaded
if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "claude" && -z "$ZSH_COPILOT_KEY_CHECKED" ]]; then
    zsh_copilot_debug "Initiating API key check for Anthropic"
    check_anthropic_key
    export ZSH_COPILOT_KEY_CHECKED=1
    zsh_copilot_debug "API key check completed for Anthropic"
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

zsh_copilot_debug "Configuration loaded successfully"