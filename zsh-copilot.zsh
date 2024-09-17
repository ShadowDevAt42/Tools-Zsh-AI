#!/usr/bin/env zsh

# Initialize script
SCRIPT_DIR="${0:A:h}"
source "${SCRIPT_DIR}/zsh-copilot-config.zsh"

zsh_copilot_debug "Script directory: $SCRIPT_DIR"
zsh_copilot_debug "Starting zsh-copilot.zsh"

# Load required modules
for module in "llm" "utils"; do
    zsh_copilot_debug "Loading ${module} module from $SCRIPT_DIR/zsh-copilot-${module}.zsh"
    source "${SCRIPT_DIR}/zsh-copilot-${module}.zsh"
    zsh_copilot_debug "${module} module loaded"
done

# Main suggestion function
function _suggest_ai() {
    zsh_copilot_debug "Entering _suggest_ai function"

    local PROMPT
    if [[ "${ZSH_COPILOT_CONFIG[SEND_CONTEXT]}" == 'true' ]]; then
        PROMPT="$SYSTEM_PROMPT 
            Context: You are user $(whoami) with id $(id) in directory $(pwd). 
            Your shell is $(echo $SHELL) and your terminal is $(echo $TERM) running on $(uname -a).
            $SYSTEM"
        zsh_copilot_debug "Context-aware prompt created"
    else
        PROMPT="$SYSTEM_PROMPT"
        zsh_copilot_debug "Using basic system prompt"
    fi
    
    local input=$(echo "${BUFFER:0:$CURSOR}" | tr '\n' ';' | sed 's/"/\\"/g')
    zsh_copilot_debug "User input: $input"

    _zsh_autosuggest_clear
    zsh_copilot_debug "Autosuggestions cleared"
    
    local LLM_INFO
    case "${ZSH_COPILOT_CONFIG[LLM_PROVIDER]}" in
        "openai")  LLM_INFO="OpenAI ${ZSH_COPILOT_CONFIG[OPENAI_MODEL]}" ;;
        "ollama")  LLM_INFO="Ollama ${ZSH_COPILOT_CONFIG[OLLAMA_MODEL]}" ;;
        "gemini")  LLM_INFO="Google ${ZSH_COPILOT_CONFIG[GEMINI_MODEL]}" ;;
        "mistral") LLM_INFO="Mistral ${ZSH_COPILOT_CONFIG[MISTRAL_MODEL]}" ;;
        "claude")  LLM_INFO="Anthropic ${ZSH_COPILOT_CONFIG[ANTHROPIC_MODEL]}" ;;
        *)         LLM_INFO="Unknown LLM Provider" ;;
    esac

    zle -R "Thinking... $LLM_INFO"
    zsh_copilot_debug "Using ${ZSH_COPILOT_CONFIG[LLM_PROVIDER]} provider"

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

# Information display function
function zsh-copilot() {
    zsh_copilot_debug "Entering zsh-copilot function"
    echo "ZSH Copilot is now active. Press ${ZSH_COPILOT_CONFIG[KEY]} to get suggestions."
    echo ""
    echo "Configurations:"
    for key in ${(k)ZSH_COPILOT_CONFIG}; do
        echo "    - ZSH_COPILOT_${key}: ${ZSH_COPILOT_CONFIG[$key]}"
    done
    if [[ "${ZSH_COPILOT_CONFIG[DEBUG]}" == "true" ]]; then
        echo "    - Debug log file: $ZSH_COPILOT_LOG_FILE"
    fi
    echo ""
    echo "API Keys:"
    for api_key in OPENAI_API_KEY GOOGLE_API_KEY MISTRAL_API_KEY CLAUDE_API_KEY; do
        if [[ -n "${(P)api_key}" ]]; then
            echo "    - $api_key: Set"
        else
            echo "    - $api_key: Not Set"
        fi
    done
    zsh_copilot_debug "Exiting zsh-copilot function"
}

# Set up ZLE widget and key binding
zle -N _suggest_ai
bindkey ${ZSH_COPILOT_CONFIG[KEY]} _suggest_ai
zsh_copilot_debug "Keybinding set for _suggest_ai: ${ZSH_COPILOT_CONFIG[KEY]}"

zsh_copilot_debug "zsh-copilot.zsh loaded successfully"