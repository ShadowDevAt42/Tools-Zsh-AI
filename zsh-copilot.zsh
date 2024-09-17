#!/usr/bin/env zsh
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/zsh-copilot-config.zsh"
source "${SCRIPT_DIR}/zsh-copilot-llm.zsh"
source "${SCRIPT_DIR}/zsh-copilot-utils.zsh"

function _suggest_ai() {
    if [[ "$ZSH_COPILOT_SEND_CONTEXT" == 'true' ]]; then
        local PROMPT="$SYSTEM_PROMPT 
            Context: You are user $(whoami) with id $(id) in directory $(pwd). 
            Your shell is $(echo $SHELL) and your terminal is $(echo $TERM) running on $(uname -a).
            $SYSTEM"
    else
        local PROMPT="$SYSTEM_PROMPT"
    fi
    
    local input=$(echo "${BUFFER:0:$CURSOR}" | tr '\n' ';')
    input=$(echo "$input" | sed 's/"/\\"/g')

    _zsh_autosuggest_clear
    
    # Personnalisation du message "Thinking" en fonction du modèle
    if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "openai" ]]; then
        zle -R "Thinking OpenAI..."
    elif [[ "$ZSH_COPILOT_LLM_PROVIDER" == "ollama" ]]; then
        zle -R "Thinking Ollama..."
    else
        zle -R "Thinking..."
    fi

    PROMPT=$(echo "$PROMPT" | tr -d '\n')

    local message=$(get_ai_suggestion "$input" "$PROMPT")

    local first_char=${message:0:1}
    local suggestion=${message:1}
    
    debug_log "$input" "$message" "$first_char" "$suggestion" "$PROMPT"

    if [[ "$first_char" == '=' ]]; then
        BUFFER=""
        CURSOR=0
        zle -U "$suggestion"
    elif [[ "$first_char" == '+' ]]; then
        _zsh_autosuggest_suggest "$suggestion"
    else
        zle -R "Error: Invalid AI response"
        return 1
    fi
}

function zsh-copilot() {
    echo "ZSH Copilot is now active. Press $ZSH_COPILOT_KEY to get suggestions."
    echo ""
    echo "Configurations:"
    echo "    - ZSH_COPILOT_KEY: Key to press to get suggestions (default: ^z, value: $ZSH_COPILOT_KEY)."
    echo "    - ZSH_COPILOT_SEND_CONTEXT: If \`true\`, zsh-copilot will send context information (whoami, shell, pwd, etc.) to the AI model (default: true, value: $ZSH_COPILOT_SEND_CONTEXT)."
    echo "    - ZSH_COPILOT_LLM_PROVIDER: The LLM provider to use (default: openai, value: $ZSH_COPILOT_LLM_PROVIDER)."
    echo "    - ZSH_COPILOT_OPENAI_MODEL: The OpenAI model to use (default: gpt-4, value: $ZSH_COPILOT_OPENAI_MODEL)."
    echo "    - ZSH_COPILOT_OLLAMA_MODEL: The Ollama model to use (default: llama3.1:8b, value: $ZSH_COPILOT_OLLAMA_MODEL)."
    echo ""
    echo "API Keys:"
    echo "    - OPENAI_API_KEY: ${OPENAI_API_KEY:+Set} ${OPENAI_API_KEY:-Not Set}"
}

zle -N _suggest_ai
bindkey $ZSH_COPILOT_KEY _suggest_ai