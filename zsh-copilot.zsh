#!/usr/bin/env zsh

SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/zsh-copilot-config.zsh"

zsh_copilot_debug "Script directory: $SCRIPT_DIR"
zsh_copilot_debug "Starting zsh-copilot.zsh"
zsh_copilot_debug "OPENAI_API_KEY: ${OPENAI_API_KEY:+is set (length: ${#OPENAI_API_KEY})} ${OPENAI_API_KEY:-is not set}"

zsh_copilot_debug "Loading LLM module from $SCRIPT_DIR/zsh-copilot-llm.zsh"
source "${SCRIPT_DIR}/zsh-copilot-llm.zsh"
zsh_copilot_debug "LLM module loaded"

zsh_copilot_debug "Loading utils from $SCRIPT_DIR/zsh-copilot-utils.zsh"
source "${SCRIPT_DIR}/zsh-copilot-utils.zsh"
zsh_copilot_debug "Utils loaded"

zsh_copilot_debug "OPENAI_API_KEY after loading modules: ${OPENAI_API_KEY:+is set (length: ${#OPENAI_API_KEY})} ${OPENAI_API_KEY:-is not set}"

function _suggest_ai() {
    zsh_copilot_debug "Entering _suggest_ai function"
    if [[ "$ZSH_COPILOT_SEND_CONTEXT" == 'true' ]]; then
        local PROMPT="$SYSTEM_PROMPT 
            Context: You are user $(whoami) with id $(id) in directory $(pwd). 
            Your shell is $(echo $SHELL) and your terminal is $(echo $TERM) running on $(uname -a).
            $SYSTEM"
        zsh_copilot_debug "Context-aware prompt created"
    else
        local PROMPT="$SYSTEM_PROMPT"
        zsh_copilot_debug "Using basic system prompt"
    fi
    
    local input=$(echo "${BUFFER:0:$CURSOR}" | tr '\n' ';')
    input=$(echo "$input" | sed 's/"/\\"/g')
    zsh_copilot_debug "User input: $input"

    _zsh_autosuggest_clear
    zsh_copilot_debug "Autosuggestions cleared"
    
    zle -R "Thinking..."
    zsh_copilot_debug "Using $ZSH_COPILOT_LLM_PROVIDER provider"

    PROMPT=$(echo "$PROMPT" | tr -d '\n')
    zsh_copilot_debug "Final prompt prepared"

    local message=$(get_ai_suggestion "$input" "$PROMPT")
    
    if [[ $? -ne 0 ]]; then
        zsh_copilot_debug "Error occurred in get_ai_suggestion"
        zle -R "Error: Failed to get AI suggestion"
        return 1
    fi

    zsh_copilot_debug "AI suggestion received: $message"

    local first_char=${message:0:1}
    local suggestion=${message:1}
    
    debug_log "$input" "$message" "$first_char" "$suggestion" "$PROMPT"

    if [[ "$first_char" == '=' ]]; then
        zsh_copilot_debug "New command suggested"
        BUFFER="$suggestion"
        CURSOR=${#BUFFER}
    elif [[ "$first_char" == '+' ]]; then
        zsh_copilot_debug "Command completion suggested"
        _zsh_autosuggest_suggest "$suggestion"
    else
        zsh_copilot_debug "Error: Invalid AI response"
        zle -R "Error: Invalid AI response"
        return 1
    fi
    zsh_copilot_debug "Exiting _suggest_ai function"
}

function zsh-copilot() {
    zsh_copilot_debug "Entering zsh-copilot function"
    echo "ZSH Copilot is now active. Press $ZSH_COPILOT_KEY to get suggestions."
    echo ""
    echo "Configurations:"
    echo "    - ZSH_COPILOT_KEY: Key to press to get suggestions (default: ^z, value: $ZSH_COPILOT_KEY)."
    echo "    - ZSH_COPILOT_SEND_CONTEXT: If \`true\`, zsh-copilot will send context information (default: true, value: $ZSH_COPILOT_SEND_CONTEXT)."
    echo "    - ZSH_COPILOT_LLM_PROVIDER: The LLM provider to use (default: openai, value: $ZSH_COPILOT_LLM_PROVIDER)."
    echo "    - ZSH_COPILOT_OPENAI_MODEL: The OpenAI model to use (default: gpt-4, value: $ZSH_COPILOT_OPENAI_MODEL)."
    echo "    - ZSH_COPILOT_OLLAMA_MODEL: The Ollama model to use (default: llama3.1:8b, value: $ZSH_COPILOT_OLLAMA_MODEL)."
    echo "    - ZSH_COPILOT_GEMINI_MODEL: The Google Gemini model to use (default: gemini-1.5-flash-latest, value: $ZSH_COPILOT_GEMINI_MODEL)."
    echo "    - ZSH_COPILOT_DEBUG: Debug mode (default: false, value: $ZSH_COPILOT_DEBUG)"
    if [[ "$ZSH_COPILOT_DEBUG" == "true" ]]; then
        echo "    - Debug log file: $ZSH_COPILOT_LOG_FILE"
    fi
    echo ""
    echo "API Keys:"
    echo "    - OPENAI_API_KEY: ${OPENAI_API_KEY:+Set} ${OPENAI_API_KEY:-Not Set}"
    echo "    - GOOGLE_API_KEY: ${GOOGLE_API_KEY:+Set} ${GOOGLE_API_KEY:-Not Set}"
    zsh_copilot_debug "Exiting zsh-copilot function"
}

zle -N _suggest_ai
bindkey $ZSH_COPILOT_KEY _suggest_ai
zsh_copilot_debug "Keybinding set for _suggest_ai: $ZSH_COPILOT_KEY"

zsh_copilot_debug "zsh-copilot.zsh loaded successfully"