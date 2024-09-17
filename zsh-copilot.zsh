#!/usr/bin/env zsh

source "${0:A:h}/zsh-copilot-config.zsh"
source "${0:A:h}/zsh-copilot-utils.zsh"

function _suggest_ai() {
    if [[ "$ZSH_COPILOT_SEND_CONTEXT" == 'true' ]]; then
        local PROMPT="$SYSTEM_PROMPT 
            Context: You are user $(whoami) with id $(id) in directory $(pwd). 
            Your shell is $(echo $SHELL) and your terminal is $(echo $TERM) running on $(uname -a).
            $SYSTEM"
    fi
    
    local input=$(echo "${BUFFER:0:$CURSOR}" | tr '\n' ';')
    input=$(echo "$input" | sed 's/"/\\"/g')

    _zsh_autosuggest_clear
    zle -R "Thinking..."

    PROMPT=$(echo "$PROMPT" | tr -d '\n')

    local data="{
        \"model\": \"$ZSH_COPILOT_OLLAMA_MODEL\",
        \"prompt\": \"$PROMPT\n\nUser: $input\nPlease provide a single command suggestion, prefixed with '=' for a new command or '+' for a completion. Do not provide explanations.\",
        \"stream\": false
    }"

    local response=$(curl "${ZSH_COPILOT_OLLAMA_URL}/api/generate" \
        --silent \
        -H "Content-Type: application/json" \
        -d "$data")

    local cleaned_response=$(echo "$response" | tr -d '\000-\037')
    local full_message=$(echo "$cleaned_response" | jq -r '.response // empty' 2>/dev/null)
    if [[ -z "$full_message" ]]; then
        full_message=$(echo "$cleaned_response" | grep -oP '(?<="response":")[^"]*')
    fi

    if [[ -z "$full_message" ]]; then
        zle -R "Error: Unable to parse AI response"
        return 1
    fi

    local message=$(echo "$full_message" | head -n 1)
    local first_char=${message:0:1}
    local suggestion=${message:1}
    
    debug_log "$input" "$cleaned_response" "$first_char" "$suggestion" "$data"

    if [[ "$first_char" == '=' ]]; then
        BUFFER=""
        CURSOR=0
        zle -U "$suggestion"
    elif [[ "$first_char" == '+' ]]; then
        _zsh_autosuggest_suggest "$suggestion"
    else
        BUFFER=""
        CURSOR=0
        zle -U "$message"
    fi
}

function zsh-copilot() {
    echo "ZSH Copilot is now active. Press $ZSH_COPILOT_KEY to get suggestions."
    echo ""
    echo "Configurations:"
    echo "    - ZSH_COPILOT_KEY: Key to press to get suggestions (default: ^z, value: $ZSH_COPILOT_KEY)."
    echo "    - ZSH_COPILOT_SEND_CONTEXT: If \`true\`, zsh-copilot will send context information (whoami, shell, pwd, etc.) to the AI model (default: true, value: $ZSH_COPILOT_SEND_CONTEXT)."
    echo "    - ZSH_COPILOT_OLLAMA_URL: URL of the Ollama API (default: http://localhost:11434, value: $ZSH_COPILOT_OLLAMA_URL)."
    echo "    - ZSH_COPILOT_OLLAMA_MODEL: Ollama model to use (default: llama3, value: $ZSH_COPILOT_OLLAMA_MODEL)."
}

zle -N _suggest_ai
bindkey $ZSH_COPILOT_KEY _suggest_ai